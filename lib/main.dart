import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/fcm_service.dart';

// Background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background messages are handled silently — notification is shown by FCM automatically
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Deep link handler for email verification / magic links
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) {
    Supabase.instance.client.auth.getSessionFromUrl(uri);
  });

  runApp(const ProviderScope(child: ZussGoApp()));
}

class ZussGoApp extends ConsumerStatefulWidget {
  const ZussGoApp({super.key});

  @override
  ConsumerState<ZussGoApp> createState() => _ZussGoAppState();
}

class _ZussGoAppState extends ConsumerState<ZussGoApp> {
  @override
  void initState() {
    super.initState();
    // Initialize FCM after app starts — registers token + sets up listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FcmService.instance.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZussGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
    );
  }
}
