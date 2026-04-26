class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id:         json['id'] as String,
      senderId:   json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content:    json['content'] as String,
      createdAt:  DateTime.parse(json['created_at'] as String),
      isRead:     json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'sender_id':   senderId,
    'receiver_id': receiverId,
    'content':     content,
    'is_read':     isRead,
  };
}