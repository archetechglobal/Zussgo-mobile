// lib/features/notifications/providers/notifications_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../data/notifications_repository.dart';
import '../../connections/data/connections_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

// ── Live stream of all notifications for current user ──────────────────────
final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final repo   = ref.watch(notificationsRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.notificationsStream(userId);
});

// ── Unread badge count ─────────────────────────────────────────────────────
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsStreamProvider).when(
    data:    (list) => list.where((n) => !n.isRead).length,
    loading: () => 0,
    error:   (_, __) => 0,
  );
});

// ── Mark ALL notifications read ────────────────────────────────────────────
final markAllReadProvider = FutureProvider<void>((ref) async {
  final repo   = ref.read(notificationsRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  await repo.markAllRead(userId);
});

// ── Mark a single notification read (keyed by notif id) ───────────────────
final markReadProvider = FutureProvider.family<void, String>((ref, notifId) async {
  final repo = ref.read(notificationsRepositoryProvider);
  await repo.markRead(notifId);
});

// ── Accept a connection request (keyed by connection id) ───────────────────
final acceptRequestProvider = FutureProvider.family<void, String>((ref, connectionId) async {
  final repo = ConnectionsRepository();
  await repo.respondToRequest(connectionId: connectionId, accept: true);
});

// ── Decline a connection request (keyed by connection id) ──────────────────
final declineRequestProvider = FutureProvider.family<void, String>((ref, connectionId) async {
  final repo = ConnectionsRepository();
  await repo.respondToRequest(connectionId: connectionId, accept: false);
});