import 'package:cloud_firestore/cloud_firestore.dart';

/// Message model for chat
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String? text;
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, List<String>>? reactions; // {emoji: [userId, userId, ...]}

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    this.text,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    required this.timestamp,
    this.isRead = false,
    this.reactions,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Safe parsing to avoid "null not a subtype of string" errors
    String safeString(dynamic value, String fallback) {
      if (value == null) return fallback;
      if (value is String) return value;
      return value.toString();
    }
    
    // Vue web uses 'content' field, Flutter uses 'text' - support both!
    // Priority: content > text (web sends 'content')
    String? messageText = json['content'] as String?;
    if (messageText == null || messageText.isEmpty) {
      messageText = json['text'] as String?;
    }
    
    // Vue web uses 'imageUrl' or 'fileUrl' for images
    String? imageUrl = json['imageUrl'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) {
      // Check if it's an image type message with fileUrl
      if (json['type'] == 'image' && json['fileUrl'] != null) {
        imageUrl = json['fileUrl'] as String?;
      }
    }
    
    // Vue web uses 'audioUrl' for voice messages
    String? audioUrl = json['audioUrl'] as String?;
    if (audioUrl == null || audioUrl.isEmpty) {
      if (json['type'] == 'audio' && json['fileUrl'] != null) {
        audioUrl = json['fileUrl'] as String?;
      }
    }
    
    // Parse reactions from Firestore (Map<String, List<dynamic>>)
    Map<String, List<String>>? reactions;
    if (json['reactions'] != null) {
      final rawReactions = json['reactions'] as Map<String, dynamic>;
      reactions = {};
      rawReactions.forEach((emoji, users) {
        if (users is List) {
          reactions![emoji] = users.map((u) => u.toString()).toList();
        }
      });
    }
    
    return MessageModel(
      id: safeString(json['id'], ''),
      chatId: safeString(json['chatId'], ''),
      senderId: safeString(json['senderId'], ''),
      receiverId: safeString(json['receiverId'], ''),
      text: messageText,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      videoUrl: json['videoUrl'] as String?,
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      reactions: reactions,
    );
  }

  Map<String, dynamic> toJson() {
    // Use 'content' field for compatibility with Vue web
    // Also keep 'text' for backwards compatibility
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': text, // Vue web uses 'content'
      'text': text, // Keep for backwards compatibility
      'type': imageUrl != null ? 'image' : (audioUrl != null ? 'audio' : (videoUrl != null ? 'video' : 'text')),
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      if (reactions != null) 'reactions': reactions,
    };
  }
}

/// Chat model (matches Vue Chat structure)
class ChatModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Timestamp? lastMessageTimestamp; // For Firestore queries
  final String? lastMessageSenderId;
  final Map<String, dynamic>? lastReadBy; // {userId: timestamp}
  final int unreadCount;
  final String? jobTitle;
  final String? jobPostId;
  final bool? isArchived;
  final bool? isMuted;
  final Map<String, dynamic>? participantDetails; // {userId: {name, photo, etc}}
  final String? applicantName; // For employer view

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageTimestamp,
    this.lastMessageSenderId,
    this.lastReadBy,
    this.unreadCount = 0,
    this.jobTitle,
    this.jobPostId,
    this.isArchived,
    this.isMuted,
    this.participantDetails,
    this.applicantName,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate() ??
          (json['lastMessageTimestamp'] as Timestamp?)?.toDate(),
      lastMessageTimestamp: json['lastMessageTimestamp'] as Timestamp?,
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      lastReadBy: json['lastReadBy'] as Map<String, dynamic>?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      jobTitle: json['jobTitle'] as String?,
      jobPostId: json['jobPostId'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      participantDetails: json['participantDetails'] as Map<String, dynamic>?,
      applicantName: json['applicantName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'lastMessageTimestamp': lastMessageTimestamp,
      'lastMessageSenderId': lastMessageSenderId,
      'lastReadBy': lastReadBy,
      'unreadCount': unreadCount,
      'jobTitle': jobTitle,
      'jobPostId': jobPostId,
      'isArchived': isArchived ?? false,
      'isMuted': isMuted ?? false,
      'participantDetails': participantDetails,
      'applicantName': applicantName,
    };
  }
}

