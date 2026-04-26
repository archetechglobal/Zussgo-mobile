import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/message_model.dart';

class ChatRepository {
  Future<List<MessageModel>> getMessages({
    required String userId,
    required String peerId,
    int limit = 50,
  }) async {
    final data = await supabase
        .from(AppConstants.messagesTable)
        .select()
        .or('and(sender_id.eq.$userId,receiver_id.eq.$peerId),'
        'and(sender_id.eq.$peerId,receiver_id.eq.$userId)')
        .order('created_at', ascending: true)
        .limit(limit);
    return (data as List).map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    await supabase.from(AppConstants.messagesTable).insert({
      'sender_id':   senderId,
      'receiver_id': receiverId,
      'content':     content,
      'is_read':     false,
    });
  }

  Stream<List<MessageModel>> messagesStream({
    required String userId,
    required String peerId,
  }) {
    return supabase
        .from(AppConstants.messagesTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((rows) => rows
        .where((r) =>
    (r['sender_id'] == userId && r['receiver_id'] == peerId) ||
        (r['sender_id'] == peerId && r['receiver_id'] == userId))
        .map((e) => MessageModel.fromJson(e))
        .toList());
  }

  Future<void> markAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    await supabase
        .from(AppConstants.messagesTable)
        .update({'is_read': true})
        .eq('sender_id', senderId)
        .eq('receiver_id', receiverId)
        .eq('is_read', false);
  }

  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    final data = await supabase
        .from(AppConstants.messagesTable)
        .select('*, profiles!messages_sender_id_fkey(id, name, avatar_url)')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);
    // De-duplicate by peer
    final Map<String, Map<String, dynamic>> seen = {};
    for (final row in (data as List)) {
      final peer = row['sender_id'] == userId
          ? row['receiver_id'] as String
          : row['sender_id'] as String;
      if (!seen.containsKey(peer)) seen[peer] = row;
    }
    return seen.values.toList();
  }
}