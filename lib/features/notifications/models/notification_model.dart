// lib/features/notifications/models/notification_model.dart

enum NotificationType { connection, message, trip, system, trip_request, match_alert, accepted, review }

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.data = const {},
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'system';
    return NotificationModel(
      id:        json['id'] as String,
      userId:    json['user_id'] as String,
      title:     json['title'] as String,
      body:      json['body'] as String,
      type:      NotificationType.values.firstWhere(
            (e) => e.name == typeStr,
        orElse: () => NotificationType.system,
      ),
      isRead:    json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      data:      (json['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// Convenience: pull a related entity id out of the data JSON.
  String? get relatedId => data['id'] as String?;

  /// Human-readable time ago string used in the notification tile.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    if (diff.inDays < 7)      return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  /// The type as a raw string — used in switch/if comparisons in the screen.
  String get typeString => type.name;
}