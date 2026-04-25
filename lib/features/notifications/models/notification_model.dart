// lib/features/notifications/models/notification_model.dart

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> m) =>
      NotificationModel(
        id:        m['id'] as String,
        userId:    m['user_id'] as String,
        type:      m['type'] as String,
        title:     m['title'] as String,
        body:      m['body'] as String,
        data:      Map<String, dynamic>.from(m['data'] as Map? ?? {}),
        isRead:    m['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  // Time display helper
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays == 1)    return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}