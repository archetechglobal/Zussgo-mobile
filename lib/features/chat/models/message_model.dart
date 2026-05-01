// lib/features/chat/models/message_model.dart

class MessageModel {
  final String  id;
  final String  connectionId;
  final String  senderId;
  final String  content;
  final String  type;
  final DateTime createdAt;
  final DateTime? readAt;

  const MessageModel({
    required this.id,
    required this.connectionId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) {
    return MessageModel(
      id:           j['id'] as String,
      connectionId: j['connection_id'] as String,
      senderId:     j['sender_id'] as String,
      content:      j['content'] as String,
      type:         j['type'] as String? ?? 'text',
      createdAt:    DateTime.parse(j['created_at'] as String),
      readAt:       j['read_at'] != null
          ? DateTime.parse(j['read_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'connection_id': connectionId,
    'sender_id':     senderId,
    'content':       content,
    'type':          type,
    'created_at':    createdAt.toIso8601String(),
    'read_at':       readAt?.toIso8601String(),
  };
}
