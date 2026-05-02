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

    // Token refresh listener — always active
    _messaging.onTokenRefresh.listen(_saveToken);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Background tap handler
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Terminated state tap handler
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleNavigation(initial.data);

    // Try saving token now in case user is already logged in (e.g. persisted session)
    await _registerToken();
  }

  // Called explicitly after a successful login
  Future<void> onUserLoggedIn() async {
    await _registerToken();
  }

  // ── Token Registration ────────────────────────────────────────────────────

  Future<void> _registerToken() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return; // Not logged in yet, skip
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
      payload: message.data['trip_id'],
    );
  }

  // ── Navigation Handling ───────────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    final tripId = response.payload;
    if (tripId != null && tripId.isNotEmpty) _navigateToDiscover();
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _handleNavigation(message.data);
  }

  void _handleNavigation(Map<String, dynamic> data) {
    if (data['type'] == 'trip_match') _navigateToDiscover();
  }

  void _navigateToDiscover() {
    try {
      goRouter.go('/match');
    } catch (_) {}
  }
}
