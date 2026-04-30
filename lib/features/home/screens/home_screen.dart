// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/nav_provider.dart';
import '../../profile/widgets/user_profile_sheet.dart';
import '../../trips/providers/trips_provider.dart';
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
    const bg              = Color(0xFF081314);
    final currentIndex    = ref.watch(homePageIndexProvider);
    final screenHeight    = MediaQuery.of(context).size.height;
    final topInset        = MediaQuery.of(context).padding.top;
    final bottomInset     = MediaQuery.of(context).padding.bottom;
    final heroHeight      = screenHeight * 0.63;
    final bottomNavHeight = 88.0 + bottomInset;

    // ── Search state ──────────────────────────────────────────────────────────
    final searchQuery   = ref.watch(homeSearchQueryProvider);
    final hasQuery      = searchQuery.isNotEmpty;
    final countAsync    = ref.watch(homeSearchCountProvider(searchQuery));
    final travelerCount = countAsync.asData?.value ?? 0;

    // ── Tray data ─────────────────────────────────────────────────────────────
    final myTripsAsync  = ref.watch(myTripsProvider);
    final pendingAsync  = ref.watch(tripPendingRequestsProvider);

    final hasMyTrip   = myTripsAsync.asData?.value.isNotEmpty == true;
    final myTripTitle = hasMyTrip
        ? '${myTripsAsync.asData!.value.first.destination} · Your Trip'
        : 'Plan your first trip';
    final myTripSub   = hasMyTrip
        ? myTripsAsync.asData!.value.first.dates
        : 'Find companions for any destination in India';
    final pendingCount = pendingAsync.asData?.value.length ?? 0;

    // ── Heading label ─────────────────────────────────────────────────────────
    // When searching: "12 people heading to Goa"
    // When idle:      "X people heading out soon" (all platform)
    final String travelersLabel;
    if (hasQuery) {
      final dest = _capitalize(searchQuery);
      travelersLabel = travelerCount > 0
          ? '$travelerCount ${travelerCount == 1 ? 'person' : 'people'} heading to $dest'
          : 'No one heading to ${_capitalize(searchQuery)} yet';
    } else {
      travelersLabel = travelerCount > 0
          ? '$travelerCount ${travelerCount == 1 ? 'person' : 'people'} heading out soon'
          : 'Travelers heading out soon';
    }

    // "See all" tap: pass destination query to match screen so it pre-filters
    void onSeeAll() {
      ref.read(bottomNavIndexProvider.notifier).setIndex(2);
      if (hasQuery) {
        context.go('/match', extra: {'tab': 'discover', 'destination': searchQuery});
      } else {
        context.go('/match', extra: 'discover');
      }
    }

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: bg)),

          // ── Hero pager ─────────────────────────────────────────────────────
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

          // Header (contains live search bar)
          Positioned(
            top: 0, left: 0, right: 0,
            child: HomeHeader(topInset: topInset),
          ),

          // ── Scrollable tray area ────────────────────────────────────────────
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
                    count: (travelerCount > 0 ? travelerCount : 1),
                  ),
                  const SizedBox(height: 20),

                  // ── Travelers row ─────────────────────────────────────────────
                  _TravelersRow(
                    label: travelersLabel,
                    showSeeAll: travelerCount > 0 || !hasQuery,
                    onTap: onSeeAll,
                  ),
                  const SizedBox(height: 16),

                  // ── Tray 1 — My active trip ───────────────────────────────────
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

                  // ── Tray 2 — Companion requests ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HomeInfoTray(
                      title: 'Companion requests',
                      subtitle: pendingCount > 0
                          ? '$pendingCount ${pendingCount == 1 ? 'person wants' : 'people want'} to join your trip'
                          : 'No pending requests right now',
                      badgeCount: pendingCount > 0 ? pendingCount : null,
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

          // ── Bottom nav ──────────────────────────────────────────────────────
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

// ─── Helpers ──────────────────────────────────────────────────────────────────
String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

// ─── Travelers heading row ────────────────────────────────────────────────────
class _TravelersRow extends StatelessWidget {
  final String label;
  final bool showSeeAll;
  final VoidCallback onTap;

  const _TravelersRow({
    required this.label,
    required this.showSeeAll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showSeeAll ? onTap : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFEAF7F3),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (showSeeAll)
            const Text(
              'See all →',
              style: TextStyle(
                color: Color(0xFF58DAD0),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}
