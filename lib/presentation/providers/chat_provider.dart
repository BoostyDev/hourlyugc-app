import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/message_model.dart';

/// Chat repository provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Chats stream provider for a user
final chatsProvider = StreamProvider.family<List<ChatModel>, String>((ref, userId) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.watchChats(userId);
});

/// Messages stream provider for a chat
final messagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.watchMessages(chatId);
});

/// Single chat provider - uses StreamProvider for real-time updates and participant details
final chatProvider = StreamProvider.family<ChatModel, String>((ref, chatId) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.watchChat(chatId);
});

