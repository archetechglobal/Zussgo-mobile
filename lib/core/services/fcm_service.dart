// lib/core/services/fcm_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_router.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'zussgo_matches',
    'Match Notifications',
    description: 'Notifies you when a great travel match is found',
    importance: Importance.high,
  );

  // Called once at app start — sets up listeners + channels
  Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Token refresh — keeps token fresh when FCM rotates it
    _messaging.onTokenRefresh.listen(_saveToken);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Background tap (app was in background, user tapped notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Terminated tap (app was fully closed, user tapped notification)
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleNavigation(initial.data);

    // Try saving token now (persisted session on cold start)
    await _registerToken();
  }

  // Called explicitly after a successful login
  Future<void> onUserLoggedIn() async {
    await _registerToken();
  }

  // ── Token Registration ────────────────────────────────────────────────────

  Future<void> _registerToken() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final token = await _messaging.getToken();
      if (token != null) await _saveToken(token);
    } catch (_) {}
  }

  Future<void> _saveToken(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
    } catch (_) {}
  }

  // ── Foreground Notifications ──────────────────────────────────────────────

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification == null) return;

    // Store trip_id + match_score as pipe-separated payload for tap handler
    final tripId     = message.data['trip_id'] ?? '';
    final matchScore = message.data['match_score'] ?? '';
    final destination = message.data['destination'] ?? '';
    final payload = '$tripId|$matchScore|$destination';

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
      ),
      payload: payload,
    );
  }

  // ── Navigation Handling ───────────────────────────────────────────────────

  // Tapped a local notification (foreground)
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload ?? '';
    final parts   = payload.split('|');
    final tripId  = parts.isNotEmpty ? parts[0] : '';
    _handleNavigation({'type': 'trip_match', 'trip_id': tripId});
  }

  // Tapped FCM notification while app was in background
  void _onMessageOpenedApp(RemoteMessage message) {
    _handleNavigation(message.data);
  }

  // Core navigation dispatcher
  void _handleNavigation(Map<String, dynamic> data) {
    if (data['type'] != 'trip_match') return;

    final tripId = (data['trip_id'] as String? ?? '').trim();

    try {
      if (tripId.isNotEmpty) {
        // Deep link → Discover tab, pre-scrolled to the specific trip
        goRouter.go('/match', extra: 'discover');
        // Small delay so MatchScreen mounts before we push the trip detail
        Future.delayed(const Duration(milliseconds: 350), () {
          goRouter.push('/trip/$tripId');
        });
      } else {
        // No trip id — fall back to Discover tab
        goRouter.go('/match', extra: 'discover');
      }
    } catch (_) {}
  }
}
