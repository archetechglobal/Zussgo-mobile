import 'package:go_router/go_router.dart';

import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/phone_otp_screen.dart';
import '../../features/auth/screens/email_verify_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/match/screens/match_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';   // ← list
import '../../features/chat/screens/chat_screen.dart';         // ← individual

final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',       builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/onboarding',   builder: (c, s) => const OnboardingScreen()),
    GoRoute(path: '/login',        builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/signup',       builder: (c, s) => const SignupScreen()),
    GoRoute(path: '/phone-verify', builder: (c, s) => const PhoneOtpScreen()),
    GoRoute(
      path: '/verify-email',
      builder: (c, s) => EmailVerifyScreen(email: s.extra as String),
    ),
    GoRoute(path: '/home',  name: 'home',  builder: (c, s) => const HomeScreen()),
    GoRoute(
      path: '/match',
      name: 'match',
      builder: (c, s) => MatchScreen(initialTab: s.extra as String? ?? 'discover'),
    ),

    // Chats list (tab destination)
    GoRoute(
      path: '/chat',
      name: 'chats',
      builder: (c, s) => const ChatsListScreen(),
    ),

    // Individual chat (opened from list)
    GoRoute(
      path: '/chat/:id',
      name: 'chat',
      builder: (c, s) => ChatScreen(peerId: s.pathParameters['id'] ?? ''),
    ),
  ],
);