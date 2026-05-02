// lib/features/chat/data/chat_repository.dart
// Messages are scoped to a connection (connection_id), not a sender/receiver pair.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/message_model.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart' show ItineraryItem;

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
    // Detect plan card type from content prefix
    final resolvedType =
        content.startsWith('\u{1F4CD} ') ? 'plan_card' : type;

    await supabase.from(AppConstants.messagesTable).insert({
      'connection_id': connectionId,
      'sender_id':     senderId,
      'content':       content,
      'type':          resolvedType,
    });

    // Fire-and-forget push notification — never awaited.
    supabase.functions
        .invoke(
          'send-chat-notification',
          body: {
            'connection_id': connectionId,
            'sender_id':     senderId,
            'content':       content,
          },
        )
        .catchError((_) {});
  }

  // ── Real-time message stream ───────────────────────────────────────────────
  Stream<List<MessageModel>> messagesStream({
    required String connectionId,
  }) {
    return supabase
        .from(AppConstants.messagesTable)
        .stream(primaryKey: ['id'])
        .eq('connection_id', connectionId)
        .order('created_at', ascending: true)
        .map((rows) =>
            rows.map((e) => MessageModel.fromJson(e)).toList());
  }

  // ── Mark messages as read ─────────────────────────────────────────────────
  Future<void> markMessagesRead({
    required String connectionId,
    required String userId,
  }) async {
    await supabase
        .from(AppConstants.messagesTable)
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('connection_id', connectionId)
        .neq('sender_id', userId)
        .isFilter('read_at', null);
  }

  // ── Itinerary CRUD ────────────────────────────────────────────────────────

  /// Add an itinerary item to Supabase and return the persisted [ItineraryItem].
  Future<ItineraryItem?> addItineraryItem({
    required String       connectionId,
    required String       userId,
    required PlanCardData card,
  }) async {
    final row = await supabase
        .from('itinerary_items')
        .insert({
          'connection_id': connectionId,
          'user_id':       userId,
          'place_name':    card.placeName,
          'category':      card.category,
          'date_label':    card.date,
          'time_label':    card.time,
          'emoji':         card.emoji,
        })
        .select()
        .single();
    return ItineraryItem.fromJson(row);
  }

  /// Delete an itinerary item by its Supabase row id.
  Future<void> deleteItineraryItem(String id) async {
    await supabase.from('itinerary_items').delete().eq('id', id);
  }

  /// Real-time stream of itinerary items for a connection.
  Stream<List<ItineraryItem>> itineraryStream({
    required String connectionId,
  }) {
    return supabase
        .from('itinerary_items')
        .stream(primaryKey: ['id'])
        .eq('connection_id', connectionId)
        .order('created_at', ascending: true)
        .map((rows) =>
            rows.map((e) => ItineraryItem.fromJson(e)).toList());
  }

  // ── Realtime chat list with last message + unread count ───────────────────
  Stream<List<Map<String, dynamic>>> realtimeChatPreviews(String userId) {
    return supabase
        .from(AppConstants.messagesTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((_) => _buildChatPreviews(userId));
  }

  Future<List<Map<String, dynamic>>> _buildChatPreviews(
      String userId) async {
    final connections = await supabase
        .from(AppConstants.connectionsTable)
        .select(
          'id, requester_id, receiver_id, '
          'requester:requester_id(id, name, avatar_url), '
          'receiver:receiver_id(id, name, avatar_url)',
        )
        .or('requester_id.eq.$userId,receiver_id.eq.$userId')
        .eq('status', 'accepted');

    if (connections == null || (connections as List).isEmpty) return [];

    final List<Map<String, dynamic>> result = [];

    for (final conn in (connections as List)) {
      final connId = conn['id'] as String;

      final lastMsgRows = await supabase
          .from(AppConstants.messagesTable)
          .select('content, created_at, sender_id')
          .eq('connection_id', connId)
          .order('created_at', ascending: false)
          .limit(1);

      final unreadRes = await supabase
          .from(AppConstants.messagesTable)
          .select('id')
          .eq('connection_id', connId)
          .neq('sender_id', userId)
          .isFilter('read_at', null);

      final lastMsg     = (lastMsgRows as List).isNotEmpty
          ? lastMsgRows[0]
          : null;
      final unreadCount = (unreadRes as List).length;

      result.add({
        ...Map<String, dynamic>.from(conn as Map),
        'last_message':
            lastMsg?['content'] as String? ?? '',
        'last_message_at':
            lastMsg?['created_at'] as String? ?? conn['updated_at'],
        'unread_count': unreadCount,
      });
    }

    result.sort((a, b) {
      final aTime = DateTime.tryParse(
              a['last_message_at'] as String? ?? '') ??
          DateTime(0);
      final bTime = DateTime.tryParse(
              b['last_message_at'] as String? ?? '') ??
          DateTime(0);
      return bTime.compareTo(aTime);
    });

    return result;
  }
}
