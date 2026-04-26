// lib/features/chat/data/chat_repository.dart
// Messages are scoped to a connection (connection_id), not a sender/receiver pair.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/message_model.dart';

class ChatRepository {
  // ── Resolve connection ID between current user and a peer ──────────────────
  Future<String?> getConnectionId({
    required String userId,
    required String peerId,
  }) async {
    final data = await supabase
        .from(AppConstants.connectionsTable)
        .select('id')
        .or(
      'and(requester_id.eq.$userId,receiver_id.eq.$peerId),'
          'and(requester_id.eq.$peerId,receiver_id.eq.$userId)',
    )
        .eq('status', 'accepted')
        .maybeSingle();
    return data?['id'] as String?;
  }

  // ── Fetch messages for a connection ───────────────────────────────────────
  Future<List<MessageModel>> getMessages({
    required String connectionId,
    int limit = 50,
  }) async {
    final data = await supabase
        .from(AppConstants.messagesTable)
        .select()
        .eq('connection_id', connectionId)
        .order('created_at', ascending: true)
        .limit(limit);
    return (data as List).map((e) => MessageModel.fromJson(e)).toList();
  }

  // ── Send a message ─────────────────────────────────────────────────────────
  Future<void> sendMessage({
    required String connectionId,
    required String senderId,
    required String content,
    String type = 'text',
  }) async {
    await supabase.from(AppConstants.messagesTable).insert({
      'connection_id': connectionId,
      'sender_id':     senderId,
      'content':       content,
      'type':          type,
    });
  }

  // ── Real-time stream ───────────────────────────────────────────────────────
  Stream<List<MessageModel>> messagesStream({required String connectionId}) {
    return supabase
        .from(AppConstants.messagesTable)
        .stream(primaryKey: ['id'])
        .eq('connection_id', connectionId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((e) => MessageModel.fromJson(e)).toList());
  }

  // ── Chat list for ChatsListScreen ──────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getChatPreviews(String userId) async {
    final connections = await supabase
        .from(AppConstants.connectionsTable)
        .select(
      'id, requester_id, receiver_id, updated_at, '
          'requester:requester_id(id, name, avatar_url), '
          'receiver:receiver_id(id, name, avatar_url)',
    )
        .or('requester_id.eq.$userId,receiver_id.eq.$userId')
        .eq('status', 'accepted')
        .order('updated_at', ascending: false);

    return (connections as List).cast<Map<String, dynamic>>();
  }
}