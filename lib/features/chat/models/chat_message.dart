// lib/features/chat/models/chat_message.dart

enum MessageType { text, planCard }

class PlanCardData {
  final String placeName;
  final String category;
  final String date;
  final String time;
  final String emoji;
  bool addedToItinerary;

  PlanCardData({
    required this.placeName,
    required this.category,
    required this.date,
    required this.time,
    required this.emoji,
    this.addedToItinerary = false,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final MessageType type;
  final PlanCardData? planCard;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.type = MessageType.text,
    this.planCard,
  });

  ChatMessage copyWith({PlanCardData? planCard}) {
    return ChatMessage(
      id: id,
      text: text,
      isMe: isMe,
      timestamp: timestamp,
      type: type,
      planCard: planCard ?? this.planCard,
    );
  }
}