// lib/features/chat/data/chat_repository.dart

import '../../../core/supabase/supabase_client.dart';

class ChatRepository {
  // ── Send message ──────────────────────────────────────────────────────────
  Future<void> sendMessage({
    required String connectionId,
    required String content,
    String type = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    await supabase.from('messages').insert({
      'connection_id': connectionId,
      'sender_id':     uid,
      'content':       content,
      'type':          type,
      'metadata':      metadata,
    });
  }

  // ── Fetch messages for a connection ───────────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchMessages(
      String connectionId, {int limit = 50}) async {
    final data = await supabase
        .from('messages')
        .select('*, sender:sender_id(id, name, avatar_url)')
        .eq('connection_id', connectionId)
        .order('created_at', ascending: true)
        .limit(limit);
    return List<Map<String, dynamic>>.from(data as List);
  }

  // ── Realtime stream ───────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> stream(String connectionId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('connection_id', connectionId)
        .order('created_at', ascending: true)
        .limit(50)
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  }

  // ── Fetch chat list (connections with last message) ───────────────────────
  Future<List<Map<String, dynamic>>> fetchChatList() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('connections')
        .select('''
          id, status, updated_at,
          requester:requester_id(id, name, avatar_url),
          receiver:receiver_id(id, name, avatar_url),
          trip:trip_id(destination, dates)
        ''')
        .eq('status', 'accepted')
        .or('requester_id.eq.$uid,receiver_id.eq.$uid')
        .order('updated_at', ascending: false);
    return List<Map<String, dynamic>>.from(data as List);
  }
}