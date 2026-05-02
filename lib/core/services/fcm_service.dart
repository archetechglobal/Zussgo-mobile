// lib/core/services/fcm_service.dart
//
// Handles FCM token registration, foreground notifications,
// and deep-link routing when a notification is tapped.

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Android notification channel for high-priority FCM messages
  static const _channel = AndroidNotificationChannel(
    'zussgo_matches',
    'Match Notifications',
    description: 'Notifies you when a great travel match is found',
    importance: Importance.high,
  );

  Future<void> init() async {
    // Request permission (Android 13+, iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Init local notifications (for foreground display)
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Get + save FCM token
    await _registerToken();

    // Token refresh listener
    _messaging.onTokenRefresh.listen(_saveToken);

    // Foreground message handler — show local notification
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Notification tap handler — app in background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check if app was opened from a terminated state via notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleNavigation(initial.data);
  }

  // ── Token Registration ────────────────────────────────────────────────────

  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _saveToken(token);
    } catch (_) {
      // Silently fail — non-critical, will retry on next launch
    }
  }

  Future<void> _saveToken(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
    } catch (_) {
      // Silently fail
    }
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
    if (tripId != null && tripId.isNotEmpty) {
      _navigateToDiscover();
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _handleNavigation(message.data);
  }

  void _handleNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == 'trip_match') {
      _navigateToDiscover();
    }
  }

  void _navigateToDiscover() {
    // Navigate to the Discover/Match screen
    try {
      goRouter.go('/match');
    } catch (_) {}
  }
}
