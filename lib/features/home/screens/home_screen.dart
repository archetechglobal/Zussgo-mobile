// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/nav_provider.dart';
import '../../profile/widgets/user_profile_sheet.dart';
import '../../connections/providers/connections_provider.dart';
import '../../trips/providers/trips_provider.dart';
import '../data/home_mock_data.dart';
import '../providers/home_provider.dart';
import '../widgets/hero_match_dots.dart';
import '../widgets/hero_match_pager.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_header.dart';
import '../widgets/home_info_tray.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bottomNavIndexProvider.notifier).setIndex(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF081314);
    final currentIndex    = ref.watch(homePageIndexProvider);
    final screenHeight    = MediaQuery.of(context).size.height;
    final topInset        = MediaQuery.of(context).padding.top;
    final bottomInset     = MediaQuery.of(context).padding.bottom;
    final heroHeight      = screenHeight * 0.63;
    final bottomNavHeight = 88.0 + bottomInset;

    // Live data for trays
    final myTripsAsync      = ref.watch(myTripsProvider);
    final pendingAsync      = ref.watch(tripPendingRequestsProvider);
    final activeTripsAsync  = ref.watch(activeTripsProvider);

    final activeCount  = activeTripsAsync.asData?.value.length ?? 0;
    final myTripTitle  = myTripsAsync.asData?.value.isNotEmpty == true
        ? '${myTripsAsync.asData!.value.first.destination} trip · Live'
        : 'Your trips';
    final myTripSub    = myTripsAsync.asData?.value.isNotEmpty == true
        ? '${myTripsAsync.asData!.value.first.dates}'
        : 'No active trips yet';
    final pendingCount = pendingAsync.asData?.value.length ?? 0;

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: bg)),

          // ── Hero pager (live data) ──────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0, height: heroHeight,
            child: HeroMatchPager(
              controller: _pageController,
              height: heroHeight,
              onPageChanged: (index) {
                ref.read(homePageIndexProvider.notifier).setIndex(index);
              },
              onCardTap: (match) {
                UserProfileSheet.show(context, name: match.name);
              },
            ),
          ),

          // Status-bar gradient overlay
          Positioned(
            top: 0, left: 0, right: 0,
            height: topInset + 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.38),
                    Colors.black.withOpacity(.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: HomeHeader(topInset: topInset),
          ),

          // ── Scrollable body below hero ────────────────────────────────────
          Positioned(
            top: heroHeight, left: 0, right: 0,
            bottom: bottomNavHeight,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroMatchDots(
                    currentIndex: currentIndex,
                    count: activeCount > 0 ? activeCount : 1,
                  ),
                  const SizedBox(height: 20),

                  _TravelersSeeAllRow(
                    onTap: () {
                      ref.read(bottomNavIndexProvider.notifier).setIndex(2);
                      context.go('/match', extra: 'discover');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tray 1 — My active trip
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HomeInfoTray(
                      title: myTripTitle,
                      subtitle: myTripSub,
                      onTap: () {
                        ref.read(bottomNavIndexProvider.notifier).setIndex(2);
                        context.go('/match', extra: 'discover');
                      },
                    ),
                  ),

                  // Tray 2 — Companion requests (live badge count)
                  if (pendingCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HomeInfoTray(
                        title: 'Companion requests',
                        subtitle: '$pendingCount ${pendingCount == 1 ? 'person wants' : 'people want'} to join',
                        badgeCount: pendingCount,
                        onTap: () {
                          ref.read(bottomNavIndexProvider.notifier).setIndex(2);
                          context.go('/match', extra: 'requests');
                        },
                      ),
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Bottom nav ────────────────────────────────────────────────────
          Positioned(
            left: 12, right: 12,
            bottom: 12 + bottomInset,
            child: const HomeBottomNav(),
          ),
        ],
      ),
    );
  }
}

class _TravelersSeeAllRow extends StatelessWidget {
  final VoidCallback onTap;
  const _TravelersSeeAllRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'More travelers going soon',
            style: TextStyle(
              color: Color(0xFFEAF7F3), fontSize: 15, fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'See all →',
            style: TextStyle(
              color: Color(0xFF58DAD0), fontSize: 13, fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}