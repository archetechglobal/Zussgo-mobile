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

// ── Chat list for ChatsListScreen ─────────────────────────────────────────────
final chatPreviewsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo   = ref.watch(chatRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.getChatPreviews(userId);
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
// LOCAL UI STATE — used only inside ChatScreen
// These are purely UI-layer concerns (local message list, AI spark, itinerary).
// They are NOT backed by Supabase.
// ═════════════════════════════════════════════════════════════════════════════

// ── Local message list notifier ───────────────────────────────────────────────
class MessagesNotifier extends StateNotifier<List<ChatMessage>> {
  MessagesNotifier() : super(_initialMessages);

  static final _initialMessages = [
    ChatMessage(
      id: '1',
      text: 'Hey! Excited for Goa 🌊',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ChatMessage(
      id: '2',
      text: 'Same! Should we sort accommodation first?',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
    ),
    ChatMessage(
      id: '3',
      text: 'Yeah for sure. I was thinking Anjuna or Vagator.',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
  ];

  void send(String text) {
    state = [
      ...state,
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
      ),
    ];
  }

  void addPlanCard(PlanCardData card) {
    state = [
      ...state,
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '📍 ${card.placeName}',
        isMe: true,
        timestamp: DateTime.now(),
        type: MessageType.planCard,
        planCard: card,
      ),
    ];
  }

  void markAdded(String messageId) {
    state = state.map((m) {
      if (m.id == messageId && m.planCard != null) {
        return m.copyWith(
          planCard: m.planCard!..addedToItinerary = true,
        );
      }
      return m;
    }).toList();
  }
}

final messagesProvider =
StateNotifierProvider<MessagesNotifier, List<ChatMessage>>(
      (_) => MessagesNotifier(),
);

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

// ── Place intent detection helpers ────────────────────────────────────────────
// Scans typed text for place-like keywords and returns a suggested PlanCardData.

bool detectPlaceIntent(String text) {
  final lower = text.toLowerCase();
  final keywords = [
    'curlies', 'tito', 'baga', 'anjuna', 'vagator', 'calangute',
    'cafe', 'beach', 'shack', 'bar', 'restaurant', 'hotel',
    'museum', 'fort', 'church', 'market', 'mall', 'club',
  ];
  return keywords.any((k) => lower.contains(k));
}

PlanCardData? suggestCardFromText(String text) {
  final lower = text.toLowerCase();

  if (lower.contains('curlies')) {
    return PlanCardData(
      placeName: "Curlies Beach Shack",
      category:  "Beach Bar",
      date:      "May 12",
      time:      "8:00 PM",
      emoji:     "🍹",
    );
  }
  if (lower.contains('tito')) {
    return PlanCardData(
      placeName: "Tito's Club",
      category:  "Nightclub",
      date:      "May 12",
      time:      "10:00 PM",
      emoji:     "🎉",
    );
  }
  if (lower.contains('vagator') || lower.contains('anjuna')) {
    return PlanCardData(
      placeName: lower.contains('vagator') ? "Vagator Beach" : "Anjuna Beach",
      category:  "Beach",
      date:      "May 13",
      time:      "10:00 AM",
      emoji:     "🏖",
    );
  }
  if (lower.contains('cafe')) {
    return PlanCardData(
      placeName: "Local Cafe",
      category:  "Cafe",
      date:      "May 12",
      time:      "9:00 AM",
      emoji:     "☕",
    );
  }
  // Generic fallback
  return PlanCardData(
    placeName: "Suggested Place",
    category:  "Place",
    date:      "May 12",
    time:      "12:00 PM",
    emoji:     "📍",
  );
}