import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/phone_otp_screen.dart';
import '../../features/auth/screens/email_verify_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/match/screens/match_screen.dart';
import '../../features/match/screens/trip_detail_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/my_profile_screen.dart';
import '../../features/profile/screens/user_profile_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/trips/screens/active_trip_screen.dart';
import '../../features/trips/screens/trip_rating_screen.dart';
import '../../features/setup/screens/profile_setup_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';

// ─── Shell wrapper — intercepts Android back on root tabs ────────────────────
// When the user is already at a root tab (home / match / chat / profile) and
// presses back, we minimise the app instead of exiting abruptly.
class _BackButtonShell extends StatelessWidget {
  final Widget child;
  const _BackButtonShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false means we handle every back event ourselves.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // If GoRouter can pop (there IS a previous screen), do it.
        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        } else {
          // We're at a root screen — send app to background, don't kill it.
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}

final goRouter = GoRouter(
  initialLocation: '/splash',

  errorBuilder: (context, state) {
    debugPrint('[GoRouter] Unknown route: \${state.uri} — redirecting to /splash');
    return const SplashScreen();
  },

  routes: [
    // ── Auth / onboarding (no back needed) ──────────────────────────────────
    GoRoute(path: '/splash',       builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/onboarding',   builder: (c, s) => const OnboardingScreen()),
    GoRoute(path: '/login',        builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/signup',       builder: (c, s) => const SignupScreen()),
    GoRoute(path: '/phone-verify', builder: (c, s) => const PhoneOtpScreen()),
    GoRoute(
      path: '/verify-email',
      builder: (c, s) => EmailVerifyScreen(email: (s.extra as String?) ?? ''),
    ),

    // ── Auth callback deep link ──────────────────────────────────────────────
    GoRoute(
      path: '/auth/callback',
      redirect: (context, state) async {
        final uri = state.uri;
        try {
          await Supabase.instance.client.auth.getSessionFromUrl(uri);
        } catch (e) {
          debugPrint('[GoRouter] Auth callback error: \$e');
        }
        return '/splash';
      },
    ),

    // ── Root tab screens — wrapped in _BackButtonShell ───────────────────────
    // These are the "home" destinations of the bottom nav. Back here = minimise.
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (c, s) => const _BackButtonShell(child: HomeScreen()),
    ),
    GoRoute(
      path: '/match',
      name: 'match',
      builder: (c, s) => _BackButtonShell(
        child: MatchScreen(initialTab: (s.extra as String?) ?? 'discover'),
      ),
    ),
    GoRoute(
      path: '/chat',
      name: 'chats',
      builder: (c, s) => const _BackButtonShell(child: ChatsListScreen()),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (c, s) => const _BackButtonShell(child: MyProfileScreen()),
    ),

    // ── Detail / sub screens — normal push, back returns to previous ─────────
    GoRoute(
      path: '/trip/:tripId',
      name: 'trip-detail',
      builder: (c, s) => TripDetailScreen(
        tripId: s.pathParameters['tripId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/chat/:id',
      name: 'chat',
      builder: (c, s) => ChatScreen(peerId: s.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/user/:userId',
      name: 'user-profile',
      builder: (c, s) => UserProfileScreen(
        userId: s.pathParameters['userId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/explore',
      name: 'explore',
      builder: (c, s) => const ExploreScreen(),
    ),
    GoRoute(
      path: '/setup',
      name: 'setup',
      builder: (c, s) {
        final args = s.extra as Map<String, dynamic>?;
        return ProfileSetupScreen(
          googleName:     args?['name']     as String? ?? '',
          googlePhotoUrl: args?['photoUrl'] as String? ?? '',
        );
      },
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
          tripName:        args?['tripName']    ?? 'Trip',
          partnerName:     args?['partnerName'] ?? 'Partner',
          partnerImageUrl: args?['imageUrl']    ?? '',
          startTime:       args?['startTime']   ?? 'Now',
        );
      },
    ),
    GoRoute(
      path: '/trip-rating',
      name: 'trip-rating',
      builder: (c, s) {
        final args = s.extra as Map<String, String>?;
        return TripRatingScreen(
          partnerName:     args?['partnerName'] ?? 'Partner',
          partnerImageUrl: args?['imageUrl']    ?? '',
          tripName:        args?['tripName']    ?? 'Trip',
        );
      },
    ),
  ],
);
