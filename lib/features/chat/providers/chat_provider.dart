// lib/features/chat/providers/chat_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/chat_repository.dart';
import '../models/chat_message.dart';
import '../models/message_model.dart';

final chatRepositoryProvider =
    Provider<ChatRepository>((ref) => ChatRepository());

// ── Resolve connection ID for a peer ─────────────────────────────────────────
final connectionIdProvider =
    FutureProvider.family<String?, String>((ref, peerId) async {
  final repo   = ref.watch(chatRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.getConnectionId(userId: userId, peerId: peerId);
});

// ── Real-time message stream (keyed by connectionId) ─────────────────────────
final messagesStreamProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, connectionId) {
  return ref
      .watch(chatRepositoryProvider)
      .messagesStream(connectionId: connectionId);
});

// ── Real-time itinerary stream from Supabase (keyed by connectionId) ─────────
final itineraryStreamProvider =
    StreamProvider.family<List<ItineraryItem>, String>((ref, connectionId) {
  return ref
      .watch(chatRepositoryProvider)
      .itineraryStream(connectionId: connectionId);
});

// ── Real-time chat list with unread counts ────────────────────────────────────
final chatPreviewsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repo   = ref.watch(chatRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.realtimeChatPreviews(userId);
});

// ── Send message + mark read (keyed by connectionId) ─────────────────────────
class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repo;
  final String         _connectionId;
  final String         _senderId;

  ChatNotifier(this._repo, this._connectionId, this._senderId)
      : super(const AsyncValue.data(null));

  Future<void> send(String content) async {
    if (content.trim().isEmpty) return;
    state = const AsyncValue.loading();
    try {
      await _repo.sendMessage(
        connectionId: _connectionId,
        senderId:     _senderId,
        content:      content.trim(),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markRead() async {
    await _repo.markMessagesRead(
      connectionId: _connectionId,
      userId:       _senderId,
    );
  }
}

final chatNotifierProvider =
    StateNotifierProvider.family<ChatNotifier, AsyncValue<void>, String>(
  (ref, connectionId) {
    final repo   = ref.watch(chatRepositoryProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    return ChatNotifier(repo, connectionId, userId);
  },
);

// ═════════════════════════════════════════════════════════════════════════════
// LOCAL UI STATE
// ═════════════════════════════════════════════════════════════════════════════

// ── AI Spark chip state ───────────────────────────────────────────────────────
// Holds a PlanCardData suggestion when a place is detected in typed text.
final aiSparkProvider = StateProvider<PlanCardData?>((ref) => null);

// ── Itinerary item model ──────────────────────────────────────────────────────
class ItineraryItem {
  final String id;       // Supabase row id for deletion
  final String title;
  final String subtitle;
  final String emoji;
  final String time;

  const ItineraryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.time,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> j) => ItineraryItem(
        id:       j['id'] as String,
        title:    j['place_name'] as String,
        subtitle: j['category'] as String,
        emoji:    j['emoji'] as String,
        time:     j['time_label'] as String,
      );
}

// ── Itinerary notifier — persists to Supabase ─────────────────────────────────
class ItineraryNotifier extends StateNotifier<List<ItineraryItem>> {
  final ChatRepository _repo;
  final String         _connectionId;
  final String         _userId;

  ItineraryNotifier(this._repo, this._connectionId, this._userId)
      : super([]);

  Future<void> addFromCard(PlanCardData card) async {
    final item = await _repo.addItineraryItem(
      connectionId: _connectionId,
      userId:       _userId,
      card:         card,
    );
    if (item != null) {
      state = [...state, item];
    }
  }

  Future<void> remove(int index) async {
    if (index < 0 || index >= state.length) return;
    final item = state[index];
    await _repo.deleteItineraryItem(item.id);
    final copy = [...state];
    copy.removeAt(index);
    state = copy;
  }
}

// NOTE: itineraryProvider is now keyed by connectionId so each chat has its
// own persisted itinerary. Use itineraryStreamProvider for live Supabase reads
// and ItineraryNotifier for write operations.
final itineraryNotifierProvider = StateNotifierProvider.family<
    ItineraryNotifier, List<ItineraryItem>, String>(
  (ref, connectionId) {
    final repo   = ref.watch(chatRepositoryProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    return ItineraryNotifier(repo, connectionId, userId);
  },
);

// Legacy alias kept so existing widget code compiles without changes.
// Widgets that don't have a connectionId yet can still use this; migrate
// them to itineraryNotifierProvider(connectionId) over time.
final itineraryProvider =
    StateNotifierProvider<ItineraryNotifier, List<ItineraryItem>>(
  (ref) {
    final repo   = ref.watch(chatRepositoryProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    return ItineraryNotifier(repo, '', userId);
  },
);

// ── Destination-aware place intent detection ──────────────────────────────────
bool detectPlaceIntent(String text, {List<String> extraKeywords = const []}) {
  final lower = text.toLowerCase();
  const genericKeywords = [
    'cafe', 'beach', 'bar', 'restaurant', 'hotel', 'hostel', 'club',
    'museum', 'fort', 'church', 'temple', 'market', 'mall', 'park',
    'waterfall', 'island', 'resort', 'rooftop', 'lounge', 'shack',
    'street food', 'night market', 'viewpoint', 'hiking', 'trail',
  ];
  final all = [
    ...genericKeywords,
    ...extraKeywords.map((k) => k.toLowerCase()),
  ];
  return all.any((k) => lower.contains(k));
}

// ── Debounced AI Spark suggestion via Edge Function ───────────────────────────
// Replaces the old keyword-only map with a real Perplexity-backed call.
// Falls back to the local keyword map if the edge function fails or times out.
Timer? _sparkDebounce;

Future<void> triggerAiSpark({
  required String text,
  required String connectionId,
  required String tripDestination,
  required DateTime? tripStartDate,
  required void Function(PlanCardData?) onResult,
}) async {
  _sparkDebounce?.cancel();
  _sparkDebounce = Timer(const Duration(milliseconds: 600), () async {
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'ai-spark-suggest',
        body: {
          'text':        text,
          'destination': tripDestination,
          'start_date':  tripStartDate?.toIso8601String(),
        },
      );
      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['place_name'] != null) {
        onResult(PlanCardData(
          placeName: data['place_name'] as String,
          category:  data['category']  as String? ?? 'Place',
          date:      data['date']       as String? ?? 'Day 1',
          time:      data['time']       as String? ?? '12:00 PM',
          emoji:     data['emoji']      as String? ?? '\u{1F4CD}',
        ));
        return;
      }
    } catch (_) {
      // edge function unavailable — fall through to local keyword fallback
    }
    // Local keyword fallback
    onResult(suggestCardFromText(
      text,
      tripDestination: tripDestination,
      tripStartDate:   tripStartDate,
    ));
  });
}

/// Local keyword fallback — synchronous, no network.
PlanCardData? suggestCardFromText(
  String text, {
  String    tripDestination = '',
  DateTime? tripStartDate,
}) {
  final lower = text.toLowerCase();

  String dateLabel(int offsetDays) {
    if (tripStartDate == null) return 'Day ${offsetDays + 1}';
    final d = tripStartDate.add(Duration(days: offsetDays));
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month]} ${d.day}';
  }

  if (lower.contains('beach')) {
    return PlanCardData(
      placeName: tripDestination.isNotEmpty
          ? '$tripDestination Beach'
          : 'Local Beach',
      category: 'Beach',
      date: dateLabel(0),
      time: '10:00 AM',
      emoji: '\u{1F3D6}',
    );
  }
  if (lower.contains('cafe') || lower.contains('coffee')) {
    return PlanCardData(
      placeName: 'Local Cafe',
      category: 'Cafe',
      date: dateLabel(0),
      time: '9:00 AM',
      emoji: '\u2615',
    );
  }
  if (lower.contains('bar') ||
      lower.contains('club') ||
      lower.contains('lounge')) {
    return PlanCardData(
      placeName: 'Night Out',
      category: lower.contains('club') ? 'Nightclub' : 'Bar',
      date: dateLabel(1),
      time: '9:00 PM',
      emoji: '\u{1F379}',
    );
  }
  if (lower.contains('restaurant') ||
      lower.contains('food') ||
      lower.contains('eat')) {
    return PlanCardData(
      placeName: 'Local Restaurant',
      category: 'Food',
      date: dateLabel(0),
      time: '7:00 PM',
      emoji: '\u{1F37D}',
    );
  }
  if (lower.contains('museum') || lower.contains('gallery')) {
    return PlanCardData(
      placeName: 'City Museum',
      category: 'Culture',
      date: dateLabel(0),
      time: '11:00 AM',
      emoji: '\u{1F3DB}',
    );
  }
  if (lower.contains('hik') ||
      lower.contains('trail') ||
      lower.contains('trek')) {
    return PlanCardData(
      placeName: 'Hiking Trail',
      category: 'Outdoors',
      date: dateLabel(1),
      time: '7:00 AM',
      emoji: '\u{1F97E}',
    );
  }
  if (lower.contains('market') || lower.contains('shop')) {
    return PlanCardData(
      placeName: 'Local Market',
      category: 'Shopping',
      date: dateLabel(0),
      time: '10:00 AM',
      emoji: '\u{1F6CD}',
    );
  }
  if (lower.contains('hotel') ||
      lower.contains('hostel') ||
      lower.contains('resort')) {
    return PlanCardData(
      placeName: 'Accommodation',
      category: lower.contains('hostel') ? 'Hostel' : 'Hotel',
      date: dateLabel(0),
      time: '3:00 PM',
      emoji: '\u{1F3E8}',
    );
  }
  return PlanCardData(
    placeName: 'Suggested Place',
    category: 'Place',
    date: dateLabel(0),
    time: '12:00 PM',
    emoji: '\u{1F4CD}',
  );
}
