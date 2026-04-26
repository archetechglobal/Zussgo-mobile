import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import '../data/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());

final messagesStreamProvider = StreamProvider.family<List<MessageModel>, String>((ref, peerId) {
  final repo   = ref.watch(chatRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.messagesStream(userId: userId, peerId: peerId);
});

final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo   = ref.watch(chatRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.getConversations(userId);
});

class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repo;
  final String _userId;
  final String _peerId;

  ChatNotifier(this._repo, this._userId, this._peerId)
      : super(const AsyncValue.data(null));

  Future<void> send(String content) async {
    if (content.trim().isEmpty) return;
    state = const AsyncValue.loading();
    try {
      await _repo.sendMessage(
        senderId: _userId, receiverId: _peerId, content: content.trim(),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markRead() async {
    await _repo.markAsRead(senderId: _peerId, receiverId: _userId);
  }
}

final chatNotifierProvider = StateNotifierProvider.family<ChatNotifier, AsyncValue<void>, String>(
      (ref, peerId) {
    final repo   = ref.watch(chatRepositoryProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    return ChatNotifier(repo, userId, peerId);
  },
);