// lib/features/notifications/providers/notifications_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notifications_repository.dart';
import '../models/notification_model.dart';

final notificationsRepositoryProvider =
Provider((_) => NotificationsRepository());

// ── Realtime stream of notifications ──────────────────────────────────────────
final notificationsStreamProvider =
StreamProvider<List<NotificationModel>>((ref) {
  return ref.read(notificationsRepositoryProvider).stream();
});

// ── Unread count (drives badge on home header) ────────────────────────────────
final unreadCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsStreamProvider).valueOrNull ?? [];
  return notifs.where((n) => !n.isRead).length;
});

// ── Mark read ─────────────────────────────────────────────────────────────────
final markReadProvider = FutureProvider.family<void, String>((ref, id) async {
  await ref.read(notificationsRepositoryProvider).markRead(id);
});

final markAllReadProvider = FutureProvider<void>((ref) async {
  await ref.read(notificationsRepositoryProvider).markAllRead();
});