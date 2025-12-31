import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/message_model.dart';
import '../../core/constants/app_constants.dart';

/// Chat repository for managing chats and messages
class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Cache for user data to avoid repeated fetches
  final Map<String, Map<String, dynamic>> _userCache = {};

  /// Fetch user data from Firestore - ALL users (genz + employer) are in 'users' collection
  /// This matches exactly how the Vue web app works
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    try {
      // All users are stored in 'users' collection (both genz and employer)
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        
        // Priority order for name (same as Vue web):
        // fullName > displayName > companyName > firstName > email prefix
        String? displayName = data['fullName'] as String?;
        if (displayName == null || displayName.isEmpty) {
          displayName = data['displayName'] as String?;
        }
        if (displayName == null || displayName.isEmpty) {
          displayName = data['companyName'] as String?;
        }
        if (displayName == null || displayName.isEmpty) {
          final firstName = data['firstName'] as String?;
          final lastName = data['lastName'] as String?;
          if (firstName != null && firstName.isNotEmpty) {
            displayName = lastName != null && lastName.isNotEmpty 
                ? '$firstName $lastName' 
                : firstName;
          }
        }
        if (displayName == null || displayName.isEmpty) {
          final email = data['email'] as String?;
          if (email != null && email.contains('@')) {
            displayName = email.split('@')[0];
          }
        }
        
        // Photo field - web uses photoURL (capital URL) or photoUrl as fallback
        final photoURL = data['photoURL'] ?? data['photoUrl'];
        
        final userData = {
          'displayName': displayName ?? 'User',
          'fullName': data['fullName'] ?? displayName ?? 'User',
          'name': displayName ?? 'User',
          'photoURL': photoURL,
          'firstName': data['firstName'],
          'lastName': data['lastName'],
          'email': data['email'],
          'companyName': data['companyName'],
          'userType': data['userType'],
        };
        _userCache[userId] = userData;
        return userData;
      }
    } catch (e) {
      // Silently fail - return null
    }
    return null;
  }

  /// Stream all chats for a user (real-time like Vue) with participant details
  Stream<List<ChatModel>> watchChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final chats = <ChatModel>[];
          
          for (final doc in snapshot.docs) {
            final data = doc.data();
            var chatData = {...data, 'id': doc.id};
            
            // Fetch participant details if not available
            if (data['participantDetails'] == null) {
              final participants = (data['participants'] as List<dynamic>).cast<String>();
              final participantDetails = <String, dynamic>{};
              
              for (final participantId in participants) {
                final userData = await getUserData(participantId);
                if (userData != null) {
                  participantDetails[participantId] = userData;
                }
              }
              
              // Update chat with participant details for future use
              if (participantDetails.isNotEmpty) {
                chatData['participantDetails'] = participantDetails;
                // Also update Firestore for persistence
                _firestore.collection('chats').doc(doc.id).update({
                  'participantDetails': participantDetails,
                }).catchError((_) {}); // Ignore errors
              }
            }
            
            chats.add(ChatModel.fromJson(chatData));
          }
          
          return chats;
        });
  }

  /// Stream a single chat with participant details
  Stream<ChatModel> watchChat(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists) {
            throw Exception('Chat not found');
          }
          
          final data = doc.data()!;
          var chatData = {...data, 'id': doc.id};
          
          // Fetch participant details if not available
          if (data['participantDetails'] == null) {
            final participants = (data['participants'] as List<dynamic>).cast<String>();
            final participantDetails = <String, dynamic>{};
            
            for (final participantId in participants) {
              final userData = await getUserData(participantId);
              if (userData != null) {
                participantDetails[participantId] = userData;
              }
            }
            
            // Update chat with participant details for future use
            if (participantDetails.isNotEmpty) {
              chatData['participantDetails'] = participantDetails;
              // Also update Firestore for persistence
              _firestore.collection('chats').doc(doc.id).update({
                'participantDetails': participantDetails,
              }).catchError((_) {}); // Ignore errors
            }
          }
          
          return ChatModel.fromJson(chatData);
        });
  }

  /// Stream messages for a specific chat (newest first for reverse:true ListView)
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              return MessageModel.fromJson({
                ...data,
                'id': doc.id,
                // Ensure required fields are present
                'chatId': data['chatId'] ?? chatId,
                'senderId': data['senderId'] ?? '',
                'receiverId': data['receiverId'] ?? '',
              });
            } catch (e) {
              // Skip invalid messages
              return null;
            }
          }).whereType<MessageModel>().toList();
        });
  }

  /// Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    String? text,
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
  }) async {
    // Fix: Handle both null and empty string - ensure message always has visible content
    final hasText = text != null && text.trim().isNotEmpty;
    final finalText = hasText ? text.trim() : 
                      (imageUrl != null ? '📷 Image' : 
                       audioUrl != null ? '🎵 Audio' : 
                       videoUrl != null ? '🎥 Video' : null);
    
    // Don't send empty messages without media
    if (finalText == null && imageUrl == null && audioUrl == null && videoUrl == null) {
      return;
    }
    
    final message = MessageModel(
      id: '', // Will be generated by Firestore
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: finalText ?? (imageUrl != null ? '📷 Image' : audioUrl != null ? '🎵 Audio' : videoUrl != null ? '🎥 Video' : 'Message'),
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Add message to subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());

    // Update chat's last message - show readable preview
    final lastMessageText = finalText ?? (imageUrl != null ? '📷 Image' : audioUrl != null ? '🎵 Audio' : videoUrl != null ? '🎥 Video' : 'Message');
    
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': lastMessageText,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderId,
    });
  }

  /// Mark messages as read
  Future<void> markAsRead(String chatId, String userId) async {
    final messagesSnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();

    // Update last read timestamp
    await _firestore.collection('chats').doc(chatId).update({
      'lastReadBy.$userId': FieldValue.serverTimestamp(),
    });
  }

  /// Archive a chat
  Future<void> archiveChat(String chatId, bool isArchived) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isArchived': isArchived,
    });
  }

  /// Mute a chat
  Future<void> muteChat(String chatId, bool isMuted) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isMuted': isMuted,
    });
  }

  /// Toggle reaction on a message (same logic as Vue web)
  Future<void> toggleReaction(String chatId, String messageId, String emoji, String userId) async {
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);
    
    final messageDoc = await messageRef.get();
    if (!messageDoc.exists) return;
    
    final data = messageDoc.data()!;
    final currentReactions = Map<String, List<dynamic>>.from(
      (data['reactions'] as Map<String, dynamic>?) ?? {}
    );
    
    final emojiReactions = List<String>.from(currentReactions[emoji] ?? []);
    
    if (emojiReactions.contains(userId)) {
      // Remove reaction
      emojiReactions.remove(userId);
    } else {
      // Add reaction
      emojiReactions.add(userId);
    }
    
    if (emojiReactions.isEmpty) {
      currentReactions.remove(emoji);
    } else {
      currentReactions[emoji] = emojiReactions;
    }
    
    await messageRef.update({'reactions': currentReactions});
  }

  /// Get a single chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    final doc = await _firestore.collection('chats').doc(chatId).get();
    if (!doc.exists) return null;
    return ChatModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Get or create chat between two users
  Future<String> getOrCreateChat(String userId1, String userId2) async {
    // Check if chat already exists
    final existingChats = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId1)
        .get();

    for (var doc in existingChats.docs) {
      final chat = doc.data();
      final participants = (chat['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
      if (participants.contains(userId2) && participants.length == 2) {
        return doc.id;
      }
    }

    // Create new chat
    final chatRef = await _firestore.collection('chats').add({
      'participants': [userId1, userId2],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    return chatRef.id;
  }

  /// Upload image for chat message
  Future<String?> uploadChatImage(String chatId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage
          .ref()
          .child('${AppConstants.chatFilesPath}/$chatId/images/$timestamp.jpg');
      
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// Upload video for chat message
  Future<String?> uploadChatVideo(String chatId, File videoFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage
          .ref()
          .child('${AppConstants.chatFilesPath}/$chatId/videos/$timestamp.mp4');
      
      await ref.putFile(videoFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// Upload audio for chat message
  Future<String?> uploadChatAudio(String chatId, File audioFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage
          .ref()
          .child('${AppConstants.chatFilesPath}/$chatId/audio/$timestamp.mp3');
      
      await ref.putFile(audioFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}

