// lib/features/chat/models/message_model.dart
// DB schema: messages(id, connection_id, sender_id, content, type, metadata, created_at)
// The old model used receiver_id which does NOT exist in the DB.

class MessageModel {
  final String id;
  final String connectionId;
  final String senderId;
  final String content;
  final String type;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.connectionId,
    required this.senderId,
    required this.content,
    this.type = 'text',
    this.metadata = const {},
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id:           json['id'] as String,
      connectionId: json['connection_id'] as String,
      senderId:     json['sender_id'] as String,
      content:      json['content'] as String,
      type:         json['type'] as String? ?? 'text',
      metadata:     (json['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt:    DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'connection_id': connectionId,
    'sender_id':     senderId,
    'content':       content,
    'type':          type,
    'metadata':      metadata,
  };
}