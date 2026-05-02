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

  /// Encode as a sendable string: "📍 Place • Category • Date Time"
  String toMessageContent() =>
      '\u{1F4CD} $placeName \u2022 $category \u2022 $date $time';

  /// Parse back from a message content string produced by [toMessageContent].
  /// Returns null if the string doesn't match the plan-card format.
  static PlanCardData? tryParse(String content) {
    if (!content.startsWith('\u{1F4CD} ')) return null;
    final body  = content.substring(3); // strip "📍 "
    final parts = body.split(' \u2022 ');
    if (parts.length < 3) return null;
    final dateParts = parts[2].trim().split(' ');
    final date = dateParts.first;
    final time = dateParts.length > 1
        ? dateParts.sublist(1).join(' ')
        : '';
    return PlanCardData(
      placeName: parts[0].trim(),
      category:  parts[1].trim(),
      date:      date,
      time:      time,
      emoji:     '\u{1F4CD}',
    );
  }
}

class ChatMessage {
  final String      id;
  final String      text;
  final bool        isMe;
  final DateTime    timestamp;
  final MessageType type;
  final PlanCardData? planCard;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.type     = MessageType.text,
    this.planCard,
  });

  ChatMessage copyWith({PlanCardData? planCard}) {
    return ChatMessage(
      id:        id,
      text:      text,
      isMe:      isMe,
      timestamp: timestamp,
      type:      type,
      planCard:  planCard ?? this.planCard,
    );
  }
}
