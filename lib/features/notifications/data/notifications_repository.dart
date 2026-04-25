// lib/features/notifications/data/notifications_repository.dart

import '../../../core/supabase/supabase_client.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  Future<List<NotificationModel>> fetchAll() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('notifications')
        .select('*')
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).map((e) => NotificationModel.fromMap(e)).toList();
  }

  Future<void> markRead(String id) async {
    await supabase.from('notifications').update({'is_read': true}).eq('id', id);
  }

  Future<void> markAllRead() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', uid)
        .eq('is_read', false);
  }

  Stream<List<NotificationModel>> stream() {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return const Stream.empty();
    return supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(50)
        .map((rows) => rows.map(NotificationModel.fromMap).toList());
  }
}