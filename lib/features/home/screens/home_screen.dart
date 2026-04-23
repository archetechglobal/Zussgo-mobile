import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_mock_data.dart';
import '../providers/home_provider.dart';
import '../widgets/hero_match_dots.dart';
import '../widgets/hero_match_pager.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_header.dart';
import '../widgets/home_info_tray.dart';
import '../../travelers/screens/travelers_grid_page.dart';

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF081314);
    final currentIndex = ref.watch(homePageIndexProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final heroHeight = screenHeight * 0.63;
    final bottomNavHeight = 88.0 + bottomInset;

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      body: Stack(
        children: [

          // ── Background fill ──────────────────────────────────
          Positioned.fill(child: Container(color: bg)),

          // ── Hero photo pager (full width, starts at top) ─────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: HeroMatchPager(
              controller: _pageController,
              height: heroHeight,
              onPageChanged: (index) {
                ref.read(homePageIndexProvider.notifier).setIndex(index);
              },
            ),
          ),

          // ── Top gradient scrim for header readability ─────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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

          // ── Floating header (greeting + search bar) ───────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeHeader(topInset: topInset),
          ),

          // ── Below-hero scroll area ─────────────────────────────
          Positioned(
            top: heroHeight,
            left: 0,
            right: 0,
            bottom: bottomNavHeight,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 1. Swipe dots
                  HeroMatchDots(
                    currentIndex: currentIndex,
                    count: HomeMockData.matches.length,
                  ),
                  const SizedBox(height: 20),

                  // 2. More travelers going soon → See all
                  _TravelersSeeAllRow(
                    destination: HomeMockData.matches.first.destination,
                  ),
                  const SizedBox(height: 16),

                  // 3. Compact trays: trip + companion requests
                  ...HomeMockData.trays.map(
                        (tray) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HomeInfoTray(tray: tray),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Floating bottom nav ────────────────────────────────
          Positioned(
            left: 12,
            right: 12,
            bottom: 12 + bottomInset,
            child: const HomeBottomNav(),
          ),

        ],
      ),
    );
  }
}

// ─── "More travelers going soon" row ────────────────────────────────────────

class _TravelersSeeAllRow extends ConsumerWidget {
  final String destination;
  const _TravelersSeeAllRow({required this.destination});

  static const text = Color(0xFFEAF7F3);
  static const teal2 = Color(0xFF58DAD0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Navigate to Match tab (index 2 in bottom nav)
        ref.read(bottomNavIndexProvider.notifier).setIndex(2);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'More travelers going soon',
            style: TextStyle(
              color: text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'See all →',
            style: TextStyle(
              color: teal2,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}