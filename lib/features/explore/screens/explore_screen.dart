// lib/features/explore/screens/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/nav_provider.dart';
import '../../home/widgets/home_bottom_nav.dart';
import '../data/explore_data.dart';
import '../widgets/india_map_painter.dart';
import '../widgets/destination_sheet.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────

const _kBg    = Color(0xFF070E0F);
const _kTeal  = Color(0xFF1EC9B8);
const _kTeal2 = Color(0xFF58DAD0);
const _kGold  = Color(0xFFF7B84E);
const _kText  = Color(0xFFEDF7F4);
const _kMuted = Color(0xFFA8C4BF);
const _kFaint = Color(0xFF6A8882);

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _mapCtrl;
  int _activeCategory = 0; // index into exploreCategories
  int? _highlightIndex;    // tapped destination node

  @override
  void initState() {
    super.initState();
    _mapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bottomNavIndexProvider.notifier).setIndex(1);
    });
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  String get _activeCategoryLabel =>
      exploreCategories[_activeCategory].label;

  List<ExploreDestination> get _filteredDestinations {
    if (_activeCategory == 0) return exploreDestinations;
    final label = _activeCategoryLabel.toLowerCase();
    return exploreDestinations.where((d) =>
    d.categories.isEmpty || d.categories.contains(label)
    ).toList();
  }

  List<ExploreDestination> get _hotDestinations =>
      exploreDestinations
          .where((d) => d.topTravelers.isNotEmpty)
          .where((d) => _activeCategory == 0 ||
          d.categories.contains(_activeCategoryLabel.toLowerCase()))
          .toList()
        ..sort((a, b) => b.travelerCount.compareTo(a.travelerCount));

  void _onMapTap(TapUpDetails details, Size mapSize) {
    const hitRadius = 28.0;
    final tapPos = details.localPosition;

    for (int i = 0; i < exploreDestinations.length; i++) {
      final d = exploreDestinations[i];
      if (d.topTravelers.isEmpty) continue; // skip origin-only nodes
      final nodePos = Offset(
        d.mapX * mapSize.width,
        d.mapY * mapSize.height,
      );
      if ((tapPos - nodePos).distance < hitRadius) {
        setState(() => _highlightIndex = i);
        DestinationSheet.show(context, d);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _highlightIndex = null);
        });
        return;
      }
    }
    setState(() => _highlightIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final topInset       = MediaQuery.of(context).padding.top;
    final bottomInset    = MediaQuery.of(context).padding.bottom;
    final screenSize     = MediaQuery.of(context).size;
    final bottomNavH     = 88.0 + bottomInset;

    return Scaffold(
      backgroundColor: _kBg,
      extendBody: true,
      body: Stack(
        children: [

          // ── LAYER 1: Full-screen India map ────────────────────────────────
          Positioned.fill(
            child: GestureDetector(
              onTapUp: (d) => _onMapTap(
                d,
                Size(screenSize.width, screenSize.height),
              ),
              child: AnimatedBuilder(
                animation: _mapCtrl,
                builder: (_, __) => CustomPaint(
                  painter: IndiaMapPainter(
                    animationValue: _mapCtrl.value,
                    destinations: exploreDestinations,
                    flows: exploreFlows,
                    highlightIndex: _highlightIndex,
                    activeCategory: _activeCategoryLabel,
                  ),
                  size: Size(screenSize.width, screenSize.height),
                ),
              ),
            ),
          ),

          // ── LAYER 2: Top gradient (for readability of search + chips) ─────
          Positioned(
            top: 0, left: 0, right: 0,
            height: topInset + 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _kBg.withOpacity(.96),
                    _kBg.withOpacity(.80),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── LAYER 3: Bottom gradient (for hot strip + nav) ────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: bottomNavH + 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _kBg,
                    _kBg.withOpacity(.95),
                    _kBg.withOpacity(.70),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.30, 0.60, 1.0],
                ),
              ),
            ),
          ),

          // ── LAYER 4: Search bar ───────────────────────────────────────────
          Positioned(
            top: topInset + 10,
            left: 16, right: 16,
            child: _SearchBar(),
          ),

          // ── LAYER 5: Category chip strip ──────────────────────────────────
          Positioned(
            top: topInset + 68,
            left: 0, right: 0,
            child: _CategoryStrip(
              activeIndex: _activeCategory,
              onSelect: (i) => setState(() => _activeCategory = i),
            ),
          ),

          // ── LAYER 6: Live traveler count pill (top right) ─────────────────
          Positioned(
            top: topInset + 10, right: 16,
            child: _LivePill(count: 47),
          ),

          // ── LAYER 7: Hot destinations strip + label ───────────────────────
          Positioned(
            left: 0, right: 0,
            bottom: bottomNavH + 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        margin: const EdgeInsets.only(right: 7),
                        decoration: const BoxDecoration(
                          color: _kTeal, shape: BoxShape.circle,
                        ),
                      ),
                      const Text(
                        'HOT RIGHT NOW',
                        style: TextStyle(
                          color: _kFaint, fontSize: 10,
                          fontWeight: FontWeight.w800, letterSpacing: .08,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 162,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _hotDestinations.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => _HotCard(
                      destination: _hotDestinations[i],
                      onTap: () => DestinationSheet.show(
                        context, _hotDestinations[i],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── LAYER 8: Bottom nav ───────────────────────────────────────────
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

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1819).withOpacity(.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.09)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: _kFaint, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Search destinations...',
              style: TextStyle(color: _kFaint, fontSize: 14),
            ),
          ),
          // Active dot
          Container(
            width: 7, height: 7,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
              color: _kTeal, shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Live pill ────────────────────────────────────────────────────────────────

class _LivePill extends StatefulWidget {
  final int count;
  const _LivePill({required this.count});

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _fade = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1819).withOpacity(.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kTeal.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _fade,
            child: Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                color: _kTeal, shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${widget.count} LIVE',
            style: const TextStyle(
              color: _kTeal2, fontSize: 11, fontWeight: FontWeight.w800,
              letterSpacing: .04,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category strip ───────────────────────────────────────────────────────────

class _CategoryStrip extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const _CategoryStrip({required this.activeIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: exploreCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat    = exploreCategories[i];
          final active = i == activeIndex;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? _kText
                    : const Color(0xFF0D1819).withOpacity(.88),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : Colors.white.withOpacity(.09),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 12,
                    color: active ? const Color(0xFF041818) : _kMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    cat.label,
                    style: TextStyle(
                      color: active ? const Color(0xFF041818) : _kText,
                      fontSize: 11, fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Hot destination card ─────────────────────────────────────────────────────

class _HotCard extends StatelessWidget {
  final ExploreDestination destination;
  final VoidCallback onTap;

  const _HotCard({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final d = destination;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 132, height: 162,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              if (d.imageUrl.isNotEmpty)
                Image.network(
                  d.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          d.nodeColor.withOpacity(.30),
                          const Color(0xFF0D1819),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Container(color: const Color(0xFF0D1819)),

              // Bottom gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(.82)],
                      stops: const [0.35, 1.0],
                    ),
                  ),
                ),
              ),

              // Border
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(.07)),
                  ),
                ),
              ),

              // Traveler count badge — top right
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.55),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(.10)),
                  ),
                  child: Text(
                    '+${d.travelerCount}',
                    style: const TextStyle(
                      color: _kGold, fontSize: 10, fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              // Bottom content
              Positioned(
                left: 12, right: 12, bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Live dot + count
                    Row(
                      children: [
                        Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                            color: d.nodeColor, shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${d.travelerCount} going',
                          style: TextStyle(
                            color: d.nodeColor, fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(d.name, style: const TextStyle(
                      color: _kText, fontSize: 14, fontWeight: FontWeight.w700,
                    )),
                    if (d.dateRange.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(d.dateRange, style: TextStyle(
                        color: Colors.white.withOpacity(.50), fontSize: 10,
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}