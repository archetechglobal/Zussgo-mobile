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
import '../../features/profile/screens/my_profile_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/trips/screens/active_trip_screen.dart';
import '../../features/trips/screens/trip_rating_screen.dart';
import '../../features/setup/screens/profile_setup_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';

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

    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (c, s) => const MyProfileScreen(),
    ),

    GoRoute(
      path: '/explore',
      name: 'explore',
      builder: (c, s) => const ExploreScreen(),
    ),

    GoRoute(
      path: '/setup',
      name: 'setup',
      builder: (c, s) => const ProfileSetupScreen(),
    ),

    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (c, s) => const NotificationsScreen(),
    ),

    GoRoute(
      path: '/active-trip',
      name: 'active-trip',
      builder: (c, s) {
        final args = s.extra as Map<String, String>?;
        return ActiveTripScreen(
          tripName:         args?['tripName']     ?? 'Trip',
          partnerName:      args?['partnerName']  ?? 'Partner',
          partnerImageUrl:  args?['imageUrl']     ?? '',
          startTime:        args?['startTime']    ?? 'Now',
        );
      },
    ),

    GoRoute(
      path: '/trip-rating',
      name: 'trip-rating',
      builder: (c, s) {
        final args = s.extra as Map<String, String>?;
        return TripRatingScreen(
          partnerName:      args?['partnerName'] ?? 'Partner',
          partnerImageUrl:  args?['imageUrl']    ?? '',
          tripName:         args?['tripName']    ?? 'Trip',
        );
      },
    ),
  ],
);