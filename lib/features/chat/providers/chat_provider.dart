// lib/features/chat/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/chat_repository.dart';
import '../models/chat_message.dart';
import '../models/message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());

// ── Resolve connection ID for a peer ──────────────────────────────────────────
final connectionIdProvider = FutureProvider.family<String?, String>((ref, peerId) async {
  final repo   = ref.watch(chatRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.getConnectionId(userId: userId, peerId: peerId);
});

// ── Stream messages from Supabase (keyed by connectionId) ─────────────────────
final messagesStreamProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, connectionId) {
  return ref.watch(chatRepositoryProvider).messagesStream(connectionId: connectionId);
});

// ── Realtime chat list with unread counts ─────────────────────────────────────
// StreamProvider so the list updates automatically when new messages arrive.
final chatPreviewsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repo   = ref.watch(chatRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.realtimeChatPreviews(userId);
});

// ── Send message (keyed by connectionId) ──────────────────────────────────────
class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repo;
  final String _connectionId;
  final String _senderId;

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

  /// Mark all messages in this connection as read by the current user.
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
// LOCAL UI STATE — purely UI-layer, NOT backed by Supabase
// ═════════════════════════════════════════════════════════════════════════════

// ── AI Spark chip state ────────────────────────────────────────────────────────
// Holds a PlanCardData suggestion when a place is detected in typed text.
final aiSparkProvider = StateProvider<PlanCardData?>((ref) => null);

// ── Itinerary item model ───────────────────────────────────────────────────────
class ItineraryItem {
  final String title;
  final String subtitle;
  final String emoji;
  final String time;

  const ItineraryItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.time,
  });
}

// ── Itinerary list notifier ───────────────────────────────────────────────────
class ItineraryNotifier extends StateNotifier<List<ItineraryItem>> {
  ItineraryNotifier() : super([]);

  void addFromCard(PlanCardData card) {
    state = [
      ...state,
      ItineraryItem(
        title:    card.placeName,
        subtitle: card.category,
        emoji:    card.emoji,
        time:     card.time,
      ),
    ];
  }

  void remove(int index) {
    final copy = [...state];
    copy.removeAt(index);
    state = copy;
  }
}

final itineraryProvider =
    StateNotifierProvider<ItineraryNotifier, List<ItineraryItem>>(
  (_) => ItineraryNotifier(),
);

// ── Destination-aware place intent detection ──────────────────────────────────
// Scans typed text for generic place-like keywords. Destination-specific
// keywords are injected at the call site from the trip context.

bool detectPlaceIntent(String text, {List<String> extraKeywords = const []}) {
  final lower = text.toLowerCase();
  const genericKeywords = [
    'cafe', 'beach', 'bar', 'restaurant', 'hotel', 'hostel', 'club',
    'museum', 'fort', 'church', 'temple', 'market', 'mall', 'park',
    'waterfall', 'island', 'resort', 'rooftop', 'lounge', 'shack',
    'street food', 'night market', 'viewpoint', 'hiking', 'trail',
  ];
  final all = [...genericKeywords, ...extraKeywords.map((k) => k.toLowerCase())];
  return all.any((k) => lower.contains(k));
}

/// Builds a PlanCardData suggestion from typed text.
/// [tripDestination] and [tripStartDate] are used to fill in context-aware
/// defaults instead of hardcoded Goa / May 12 values.
PlanCardData? suggestCardFromText(
  String text, {
  String tripDestination = '',
  DateTime? tripStartDate,
}) {
  final lower = text.toLowerCase();

  // Format a readable date from the trip start date, or fall back to 'Day 1'
  String dateLabel(int offsetDays) {
    if (tripStartDate == null) return 'Day ${offsetDays + 1}';
    final d = tripStartDate.add(Duration(days: offsetDays));
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]} ${d.day}';
  }

  // Keyword → suggestion map (generic; works for any destination)
  if (lower.contains('beach')) {
    return PlanCardData(
      placeName: tripDestination.isNotEmpty ? '$tripDestination Beach' : 'Local Beach',
      category: 'Beach',
      date: dateLabel(0),
      time: '10:00 AM',
      emoji: '🏖',
    );
  }
  if (lower.contains('cafe') || lower.contains('coffee')) {
    return PlanCardData(
      placeName: 'Local Cafe',
      category: 'Cafe',
      date: dateLabel(0),
      time: '9:00 AM',
      emoji: '☕',
    );
  }
  if (lower.contains('bar') || lower.contains('club') || lower.contains('lounge')) {
    return PlanCardData(
      placeName: 'Night Out',
      category: lower.contains('club') ? 'Nightclub' : 'Bar',
      date: dateLabel(1),
      time: '9:00 PM',
      emoji: '🍹',
    );
  }
  if (lower.contains('restaurant') || lower.contains('food') || lower.contains('eat')) {
    return PlanCardData(
      placeName: 'Local Restaurant',
      category: 'Food',
      date: dateLabel(0),
      time: '7:00 PM',
      emoji: '🍽',
    );
  }
  if (lower.contains('museum') || lower.contains('gallery')) {
    return PlanCardData(
      placeName: 'City Museum',
      category: 'Culture',
      date: dateLabel(0),
      time: '11:00 AM',
      emoji: '🏛',
    );
  }
  if (lower.contains('hik') || lower.contains('trail') || lower.contains('trek')) {
    return PlanCardData(
      placeName: 'Hiking Trail',
      category: 'Outdoors',
      date: dateLabel(1),
      time: '7:00 AM',
      emoji: '🥾',
    );
  }
  if (lower.contains('market') || lower.contains('shop')) {
    return PlanCardData(
      placeName: 'Local Market',
      category: 'Shopping',
      date: dateLabel(0),
      time: '10:00 AM',
      emoji: '🛍',
    );
  }
  if (lower.contains('hotel') || lower.contains('hostel') || lower.contains('resort')) {
    return PlanCardData(
      placeName: 'Accommodation',
      category: lower.contains('hostel') ? 'Hostel' : 'Hotel',
      date: dateLabel(0),
      time: '3:00 PM',
      emoji: '🏨',
    );
  }
  // Generic fallback
  return PlanCardData(
    placeName: 'Suggested Place',
    category: 'Place',
    date: dateLabel(0),
    time: '12:00 PM',
    emoji: '📍',
  );
}
