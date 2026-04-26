enum NotificationType { connection, message, trip, system }

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:         json['id'] as String,
      userId:     json['user_id'] as String,
      title:      json['title'] as String,
      body:       json['body'] as String,
      type:       NotificationType.values.firstWhere(
            (e) => e.name == (json['type'] as String? ?? 'system'),
        orElse: () => NotificationType.system,
      ),
      isRead:     json['is_read'] as bool? ?? false,
      createdAt:  DateTime.parse(json['created_at'] as String),
      relatedId:  json['related_id'] as String?,
    );
  }
}