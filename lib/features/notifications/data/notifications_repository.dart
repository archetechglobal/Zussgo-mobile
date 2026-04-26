// lib/features/notifications/data/notifications_repository.dart

import '../../../core/supabase/supabase_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  // ── Fetch all notifications for a user ─────────────────────────────────────
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final data = await supabase
        .from(AppConstants.notificationsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  // ── Mark ALL unread notifications as read for a user ───────────────────────
  Future<void> markAllRead(String userId) async {
    await supabase
        .from(AppConstants.notificationsTable)
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  // ── Mark a single notification as read ─────────────────────────────────────
  Future<void> markRead(String notifId) async {
    await supabase
        .from(AppConstants.notificationsTable)
        .update({'is_read': true})
        .eq('id', notifId);
  }

  // ── Real-time stream ───────────────────────────────────────────────────────
  Stream<List<NotificationModel>> notificationsStream(String userId) {
    return supabase
        .from(AppConstants.notificationsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((e) => NotificationModel.fromJson(e)).toList());
  }
}