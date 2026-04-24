// lib/features/chat/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';

// ── AI place-detection keywords ───────────────────────────────────────────────
// In production this calls your AI backend. For now it's a local keyword match.
const _placeKeywords = [
  'curlies', 'anjuna', 'baga', 'cafe', 'beach', 'restaurant', 'bar',
  'shack', 'resort', 'hotel', 'villa', 'airbnb', 'hostel', 'club',
  'market', 'temple', 'fort', 'museum', 'waterfall', 'trek', 'hike',
  'spiti', 'goa', 'manali', 'kasol', 'coorg', 'ooty', 'rishikesh',
  "let's go", "lets go", "we should go", "check out", "visit", "hit up",
];

// ── Mock itinerary items ──────────────────────────────────────────────────────
class ItineraryItem {
  final String time;
  final String title;
  final String subtitle;
  final String emoji;

  const ItineraryItem({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });
}

// ── Providers ─────────────────────────────────────────────────────────────────

final messagesProvider =
StateNotifierProvider<MessagesNotifier, List<ChatMessage>>((ref) {
  return MessagesNotifier();
});

final aiSparkProvider = StateProvider<PlanCardData?>((ref) => null);

final itineraryProvider =
StateNotifierProvider<ItineraryNotifier, List<ItineraryItem>>((ref) {
  return ItineraryNotifier();
});

// ── Messages notifier ─────────────────────────────────────────────────────────

class MessagesNotifier extends StateNotifier<List<ChatMessage>> {
  MessagesNotifier() : super(_mockMessages);

  void send(String text) {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isMe: true,
      timestamp: DateTime.now(),
    );
    state = [...state, msg];
  }

  void addPlanCard(PlanCardData card) {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '${card.emoji} ${card.placeName}',
      isMe: true,
      timestamp: DateTime.now(),
      type: MessageType.planCard,
      planCard: card,
    );
    state = [...state, msg];
  }

  void markAdded(String messageId) {
    state = state.map((m) {
      if (m.id == messageId && m.planCard != null) {
        final updated = PlanCardData(
          placeName: m.planCard!.placeName,
          category: m.planCard!.category,
          date: m.planCard!.date,
          time: m.planCard!.time,
          emoji: m.planCard!.emoji,
          addedToItinerary: true,
        );
        return m.copyWith(planCard: updated);
      }
      return m;
    }).toList();
  }
}

// ── Itinerary notifier ────────────────────────────────────────────────────────

class ItineraryNotifier extends StateNotifier<List<ItineraryItem>> {
  ItineraryNotifier() : super(_mockItinerary);

  void add(ItineraryItem item) {
    state = [...state, item];
  }

  void addFromCard(PlanCardData card) {
    add(ItineraryItem(
      time: card.time,
      title: card.placeName,
      subtitle: card.category,
      emoji: card.emoji,
    ));
  }
}

// ── AI spark detection ────────────────────────────────────────────────────────

bool detectPlaceIntent(String text) {
  final lower = text.toLowerCase();
  return _placeKeywords.any((k) => lower.contains(k));
}

PlanCardData? suggestCardFromText(String text) {
  final lower = text.toLowerCase();

  // Mock suggestions based on keyword match
  if (lower.contains('curlies')) {
    return PlanCardData(
      placeName: 'Curlies Beach Shack',
      category: 'Bar & Café · Anjuna, Goa',
      date: 'May 12',
      time: '5:30 PM',
      emoji: '🍹',
    );
  }
  if (lower.contains('baga') || lower.contains('beach')) {
    return PlanCardData(
      placeName: 'Baga Beach',
      category: 'Beach · North Goa',
      date: 'May 13',
      time: '10:00 AM',
      emoji: '🏖',
    );
  }
  if (lower.contains('spiti') || lower.contains('kaza')) {
    return PlanCardData(
      placeName: 'Key Monastery',
      category: 'Monastery · Spiti Valley',
      date: 'May 10',
      time: '9:00 AM',
      emoji: '🏔',
    );
  }
  if (lower.contains('cafe') || lower.contains('coffee')) {
    return PlanCardData(
      placeName: 'Artjuna Café',
      category: 'Café · Anjuna, Goa',
      date: 'May 12',
      time: '8:00 AM',
      emoji: '☕',
    );
  }
  // Generic fallback
  return PlanCardData(
    placeName: 'Suggested Place',
    category: 'Point of Interest',
    date: 'May 12',
    time: '12:00 PM',
    emoji: '📍',
  );
}

// ── Mock seed data ────────────────────────────────────────────────────────────

final _mockMessages = [
  ChatMessage(
    id: '1',
    text: 'Hey Aryan! Stoked we matched. The villa you sent looks incredible.',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  ChatMessage(
    id: '2',
    text: "Right? It's perfectly located between the beach and the main strip.",
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
  ),
  ChatMessage(
    id: '3',
    text: 'I was thinking we hit up Curlies on the first night for sunset drinks.',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    type: MessageType.planCard,
    planCard: PlanCardData(
      placeName: 'Curlies Beach Shack',
      category: 'Bar & Café · Anjuna, Goa',
      date: 'May 12',
      time: '5:30 PM',
      emoji: '🍹',
    ),
  ),
];

final _mockItinerary = [
  const ItineraryItem(
    time: '2:00 PM',
    title: 'Check-in: Anjuna Villa',
    subtitle: 'Split cost ₹4,500 each · UPI before arrival',
    emoji: '🏠',
  ),
];