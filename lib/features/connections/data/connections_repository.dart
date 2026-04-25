// lib/features/connections/data/connections_repository.dart

import '../../../core/supabase/supabase_client.dart';
import '../models/connection_model.dart';

class ConnectionsRepository {
  // ── Send a connection request ──────────────────────────────────────────────
  Future<ConnectionModel> sendRequest({
    required String receiverId,
    required String tripId,
    required String message,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    final data = await supabase.from('connections').insert({
      'requester_id': uid,
      'receiver_id':  receiverId,
      'trip_id':      tripId,
      'message':      message,
    }).select().single();

    // Create notification for receiver
    await supabase.from('notifications').insert({
      'user_id': receiverId,
      'type':    'trip_request',
      'title':   'New Trip Request',
      'body':    message,
      'data':    {'connection_id': data['id'], 'trip_id': tripId},
    });

    return ConnectionModel.fromMap(data);
  }

  // ── Fetch my connections (accepted) ───────────────────────────────────────
  Future<List<ConnectionModel>> fetchMyConnections() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('connections')
        .select('''
          *,
          requester:requester_id(id, name, avatar_url, base_city),
          receiver:receiver_id(id, name, avatar_url, base_city),
          trip:trip_id(destination, dates)
        ''')
        .eq('status', 'accepted')
        .or('requester_id.eq.$uid,receiver_id.eq.$uid')
        .order('updated_at', ascending: false);
    return (data as List).map((e) => ConnectionModel.fromMap(e)).toList();
  }

  // ── Fetch pending requests received ───────────────────────────────────────
  Future<List<ConnectionModel>> fetchPendingReceived() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('connections')
        .select('''
          *,
          requester:requester_id(id, name, avatar_url, base_city, vibes)
        ''')
        .eq('receiver_id', uid)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (data as List).map((e) => ConnectionModel.fromMap(e)).toList();
  }

  // ── Accept a request ───────────────────────────────────────────────────────
  Future<void> acceptRequest(String connectionId) async {
    final uid = supabase.auth.currentUser?.id;
    final conn = await supabase
        .from('connections')
        .update({'status': 'accepted'})
        .eq('id', connectionId)
        .select()
        .single();

    // Notify requester
    await supabase.from('notifications').insert({
      'user_id': conn['requester_id'],
      'type':    'accepted',
      'title':   'Request Accepted!',
      'body':    'Your trip request was accepted. Start chatting!',
      'data':    {'connection_id': connectionId},
    });
  }

  // ── Decline a request ─────────────────────────────────────────────────────
  Future<void> declineRequest(String connectionId) async {
    await supabase
        .from('connections')
        .update({'status': 'declined'})
        .eq('id', connectionId);
  }

  // ── Get or check connection between two users ──────────────────────────────
  Future<ConnectionModel?> getConnection(String otherUserId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;
    final data = await supabase
        .from('connections')
        .select('*')
        .or('and(requester_id.eq.$uid,receiver_id.eq.$otherUserId),and(requester_id.eq.$otherUserId,receiver_id.eq.$uid)')
        .maybeSingle();
    if (data == null) return null;
    return ConnectionModel.fromMap(data);
  }
}