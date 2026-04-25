// lib/features/explore/screens/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/nav_provider.dart';
import '../../home/widgets/home_bottom_nav.dart';
import '../../profile/widgets/user_profile_sheet.dart';
import '../../trips/screens/create_trip_sheet.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────

const _kBg     = Color(0xFF070E0F);
const _kS1     = Color(0xFF0D1819);
const _kS2     = Color(0xFF121F21);
const _kTeal   = Color(0xFF1EC9B8);
const _kTeal2  = Color(0xFF58DAD0);
const _kGold   = Color(0xFFF7B84E);
const _kText   = Color(0xFFEDF7F4);
const _kMuted  = Color(0xFFA8C4BF);
const _kFaint  = Color(0xFF6A8882);
const _kBorder = Color(0x0FFFFFFF);

// ─── Data models ──────────────────────────────────────────────────────────────

class _VibeCard {
  final String emoji;
  final String label;
  final Color startColor;
  final String filter;
  const _VibeCard(this.emoji, this.label, this.startColor, this.filter);
}

class _Destination {
  final String name;
  final String badge;
  final Color badgeColor;
  final int travelerCount;
  final String vibe;
  final String description;
  final List<String> vibeFilters;
  final List<_MatchUser> topMatches;
  final List<_OpenTrip> openTrips;
  final Color heroStart;
  const _Destination({
    required this.name, required this.badge, required this.badgeColor,
    required this.travelerCount, required this.vibe, required this.description,
    required this.vibeFilters, required this.topMatches,
    required this.openTrips, required this.heroStart,
  });
}

class _MatchUser {
  final String name;
  final int age;
  final int matchPct;
  final Color avatarColor;
  const _MatchUser(this.name, this.age, this.matchPct, this.avatarColor);
}

class _OpenTrip {
  final String title;
  final String dates;
  final String description;
  final int totalSpots;
  final int filledSpots;
  const _OpenTrip(this.title, this.dates, this.description, this.totalSpots, this.filledSpots);
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _vibes = [
  _VibeCard('🌊', 'Beach &\nSocial',   Color(0xFF1EC9B8), 'beach'),
  _VibeCard('🏔️', 'Mountains\n& Trek', Color(0xFF9FD9BE), 'mountains'),
  _VibeCard('🎪', 'Culture &\nFestivals',Color(0xFFF7B84E), 'culture'),
  _VibeCard('✨', 'Wellness\n& Retreat', Color(0xFFFFB3C1), 'wellness'),
];

final _destinations = <_Destination>[
  _Destination(
    name: 'Goa',
    badge: '🔥 #1 Most Active',
    badgeColor: _kTeal2,
    travelerCount: 78,
    vibe: '🌊 Beach & Social',
    description: 'The ultimate escape. Perfect for weekend parties, beach cafes, and meeting new people.',
    vibeFilters: ['beach'],
    heroStart: const Color(0xFF1C3E40),
    topMatches: [
      _MatchUser('Meera', 24, 97, Color(0xFFF7B84E)),
      _MatchUser('Priya', 23, 88, Color(0xFFFFB3C1)),
      _MatchUser('Dev',   26, 84, Color(0xFF1EC9B8)),
    ],
    openTrips: [
      _OpenTrip('South Goa Chill Weekend', 'May 12 – 15',
          'Looking for 2 more people to split a villa in Palolem. Very laid back vibe.', 4, 2),
    ],
  ),
  _Destination(
    name: 'Pushkar',
    badge: '🎪 Upcoming Festival',
    badgeColor: _kGold,
    travelerCount: 42,
    vibe: '🎪 Culture & Festival',
    description: 'Sacred ghats, desert vibes, and the famous Camel Fair. Culture overload in the best way.',
    vibeFilters: ['culture'],
    heroStart: const Color(0xFF36261A),
    topMatches: [
      _MatchUser('Anika', 26, 92, Color(0xFFB57BFF)),
      _MatchUser('Sara',  24, 85, Color(0xFF1EC9B8)),
    ],
    openTrips: [
      _OpenTrip('Pushkar Festival Group', 'May 18 – 21',
          'Group of 3 heading for the festival. Need 1 more. Staying in a heritage haveli.', 4, 3),
    ],
  ),
  _Destination(
    name: 'Spiti Valley',
    badge: '🏔 Adventure Pick',
    badgeColor: _kTeal2,
    travelerCount: 34,
    vibe: '🏔 Mountains & Trek',
    description: 'Raw Himalayas at 14,000ft. Monastery hops, stargazing, and the kind of silence that resets you.',
    vibeFilters: ['mountains'],
    heroStart: const Color(0xFF1A2E3A),
    topMatches: [
      _MatchUser('Arjun', 28, 94, Color(0xFFF7B84E)),
      _MatchUser('Rohan', 27, 88, Color(0xFF1EC9B8)),
    ],
    openTrips: [
      _OpenTrip('Spiti 8-Day Circuit', 'May 10 – 18',
          'Kaza base, Key monastery, Chandratal lake. Self-drive. Looking for 1–2.', 3, 2),
    ],
  ),
  _Destination(
    name: 'Kerala',
    badge: '🌿 Trending Now',
    badgeColor: _kTeal2,
    travelerCount: 56,
    vibe: '✨ Wellness & Retreat',
    description: 'Backwaters, Ayurveda, and coffee estates. The slow travel capital of India.',
    vibeFilters: ['wellness', 'beach'],
    heroStart: const Color(0xFF1A2E20),
    topMatches: [
      _MatchUser('Priya', 25, 91, Color(0xFF1EC9B8)),
      _MatchUser('Dev',   25, 87, Color(0xFFF7B84E)),
    ],
    openTrips: [
      _OpenTrip('Kerala Backwaters 5D', 'May 20 – 25',
          'Alleppey houseboat + Munnar. Chill group, open to suggestions.', 4, 2),
    ],
  ),
];

// ─── Main screen ──────────────────────────────────────────────────────────────

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String? _activeVibeFilter; // null = All
  _Destination? _openDetail;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bottomNavIndexProvider.notifier).setIndex(1);
    });
  }

  List<_Destination> get _filtered {
    if (_activeVibeFilter == null) return _destinations;
    return _destinations
        .where((d) => d.vibeFilters.contains(_activeVibeFilter))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      extendBody: true,
      body: Stack(
        children: [
          // ── Feed (or detail) ───────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _openDetail != null
                ? _DestinationDetail(
              key: ValueKey(_openDetail!.name),
              destination: _openDetail!,
              topInset: topInset,
              bottomInset: bottomInset,
              onBack: () => setState(() => _openDetail = null),
            )
                : _ExploreFeed(
              key: const ValueKey('feed'),
              topInset: topInset,
              bottomInset: bottomInset,
              activeFilter: _activeVibeFilter,
              destinations: _filtered,
              onVibeSelect: (f) => setState(() =>
              _activeVibeFilter = _activeVibeFilter == f ? null : f),
              onDestinationTap: (d) =>
                  setState(() => _openDetail = d),
            ),
          ),

          // ── Bottom nav ────────────────────────────────────────────────────
          if (_openDetail == null)
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

// ─── Explore Feed ─────────────────────────────────────────────────────────────

class _ExploreFeed extends StatelessWidget {
  final double topInset, bottomInset;
  final String? activeFilter;
  final List<_Destination> destinations;
  final ValueChanged<String> onVibeSelect;
  final ValueChanged<_Destination> onDestinationTap;

  const _ExploreFeed({
    super.key,
    required this.topInset, required this.bottomInset,
    required this.activeFilter, required this.destinations,
    required this.onVibeSelect, required this.onDestinationTap,
  });

  @override
  Widget build(BuildContext context) {
    final navH = 88.0 + bottomInset + 12;

    return CustomScrollView(
      slivers: [

        // ── Sticky header ──────────────────────────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            topInset: topInset,
            child: _ExploreHeader(),
          ),
        ),

        // ── Vibe blocks ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: const Text('Pick your vibe', style: TextStyle(
                  color: _kText, fontSize: 18, fontWeight: FontWeight.w700,
                  letterSpacing: -.2,
                )),
              ),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _vibes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final v = _vibes[i];
                    final active = activeFilter == v.filter;
                    return GestureDetector(
                      onTap: () => onVibeSelect(v.filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100, height: 110,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              v.startColor.withOpacity(active ? .40 : .25),
                              const Color(0xFF112425),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? v.startColor.withOpacity(.60)
                                : Colors.white.withOpacity(.06),
                            width: active ? 1.5 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Gradient overlay
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(.55)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            // Emoji top-right
                            Positioned(
                              top: 12, right: 12,
                              child: Text(v.emoji, style: const TextStyle(fontSize: 20)),
                            ),
                            // Label bottom-left
                            Positioned(
                              left: 12, bottom: 12,
                              child: Text(v.label, style: const TextStyle(
                                color: _kText, fontSize: 13,
                                fontWeight: FontWeight.w700, height: 1.25,
                              )),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Trending destinations ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Trending this weekend', style: TextStyle(
                      color: _kText, fontSize: 18, fontWeight: FontWeight.w700,
                      letterSpacing: -.2,
                    )),
                    Text('See all', style: TextStyle(
                      color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w700,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Destination hero cards ─────────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, navH + 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _DestHeroCard(
                  destination: destinations[i],
                  onTap: () => onDestinationTap(destinations[i]),
                ),
              ),
              childCount: destinations.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Sticky header delegate ───────────────────────────────────────────────────

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topInset;
  final Widget child;
  const _StickyHeaderDelegate({required this.topInset, required this.child});

  @override double get minExtent => topInset + 72;
  @override double get maxExtent => topInset + 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate old) => false;
}

class _ExploreHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, topInset + 10, 16, 14),
      decoration: BoxDecoration(
        color: _kBg.withOpacity(.92),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(.04))),
      ),
      child: Row(
        children: [
          // Search box
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded, color: _kFaint, size: 17),
                  const SizedBox(width: 8),
                  const Text('Where to next?', style: TextStyle(
                    color: _kFaint, fontSize: 13,
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Map button
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _kTeal.withOpacity(.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kTeal.withOpacity(.22)),
            ),
            child: Icon(Icons.map_outlined, color: _kTeal2, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── Destination hero card ────────────────────────────────────────────────────

class _DestHeroCard extends StatelessWidget {
  final _Destination destination;
  final VoidCallback onTap;
  const _DestHeroCard({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final d = destination;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.30),
              blurRadius: 30, offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hero bg gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [d.heroStart, const Color(0xFF0B1516)],
                  ),
                ),
              ),
              // Bottom dark overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(.88)],
                      stops: const [0.38, 1.0],
                    ),
                  ),
                ),
              ),

              // Badge top-left
              Positioned(
                top: 14, left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.50),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(.10)),
                  ),
                  child: Text(d.badge, style: TextStyle(
                    color: d.badgeColor, fontSize: 11,
                    fontWeight: FontWeight.w800,
                  )),
                ),
              ),

              // Bottom info
              Positioned(
                left: 16, right: 16, bottom: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(d.name, style: const TextStyle(
                            color: _kText, fontSize: 26,
                            fontWeight: FontWeight.w700, letterSpacing: -.3,
                          )),
                          const SizedBox(height: 4),
                          Text(
                            '${d.travelerCount} solo travelers going',
                            style: const TextStyle(color: _kMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Stacked avatars
                    _AvatarStack(users: d.topMatches, extra: d.travelerCount - 3),
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

class _AvatarStack extends StatelessWidget {
  final List<_MatchUser> users;
  final int extra;
  const _AvatarStack({required this.users, required this.extra});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: users.length * 20.0 + 32,
      child: Stack(
        children: [
          ...users.asMap().entries.map((e) => Positioned(
            left: e.key * 20.0,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: e.value.avatarColor.withOpacity(.80),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0B1516), width: 2),
              ),
              child: Center(
                child: Text(
                  e.value.name[0],
                  style: const TextStyle(
                    color: Colors.white, fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          )),
          Positioned(
            left: users.length * 20.0,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.10),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0B1516), width: 2),
              ),
              child: Center(
                child: Text(
                  '+$extra',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Destination Detail ───────────────────────────────────────────────────────

class _DestinationDetail extends StatelessWidget {
  final _Destination destination;
  final double topInset, bottomInset;
  final VoidCallback onBack;

  const _DestinationDetail({
    super.key,
    required this.destination,
    required this.topInset, required this.bottomInset,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final d = destination;

    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 90 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Cover hero ──────────────────────────────────────────────
              SizedBox(
                height: 300,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient bg
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [d.heroStart, const Color(0xFF0B1516)],
                        ),
                      ),
                    ),
                    // Fade bottom
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, const Color(0xFF0B1516)],
                            stops: const [0.40, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Back + share row
                    Positioned(
                      top: topInset + 10,
                      left: 16, right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _GlassBtn(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: onBack,
                          ),
                          _GlassBtn(icon: Icons.ios_share_rounded),
                        ],
                      ),
                    ),
                    // Info bottom
                    Positioned(
                      left: 16, right: 16, bottom: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _kTeal.withOpacity(.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _kTeal.withOpacity(.22)),
                            ),
                            child: Text(d.vibe, style: const TextStyle(
                              color: _kTeal2, fontSize: 10,
                              fontWeight: FontWeight.w800,
                            )),
                          ),
                          const SizedBox(height: 10),
                          Text(d.name, style: const TextStyle(
                            color: _kText, fontSize: 36,
                            fontWeight: FontWeight.w700, letterSpacing: -.4,
                          )),
                          const SizedBox(height: 8),
                          Text(d.description, style: const TextStyle(
                            color: _kMuted, fontSize: 13, height: 1.5,
                          )),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Live stats bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(.05)),
                  ),
                  child: Row(
                    children: [
                      _PulseDot(),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${d.travelerCount} travelers active here',
                              style: const TextStyle(
                                color: _kText, fontSize: 15,
                                fontWeight: FontWeight.w700,
                              )),
                          const SizedBox(height: 2),
                          const Text('High match rate for your vibe',
                              style: TextStyle(color: _kFaint, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Top matches ─────────────────────────────────────────────
              _SectionHeader(title: 'Your top matches going here', link: 'See all'),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: d.topMatches.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final u = d.topMatches[i];
                    return GestureDetector(
                      onTap: () => UserProfileSheet.show(context, name: u.name),
                      child: _MatchMiniCard(user: u),
                    );
                  },
                ),
              ),

              // ── Open trips ──────────────────────────────────────────────
              _SectionHeader(title: 'Open trips to join'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: d.openTrips.map((t) => _TripCard(trip: t)).toList(),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),

        // ── Sticky CTA "Plan a trip to X" ──────────────────────────────────
        Positioned(
          left: 12, right: 12,
          bottom: 12 + bottomInset,
          child: GestureDetector(
            onTap: () => CreateTripSheet.show(context),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kTeal2, _kTeal],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _kTeal.withOpacity(.25),
                    blurRadius: 32, offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Plan a trip to ${d.name}',
                  style: const TextStyle(
                    color: Color(0xFF041818),
                    fontSize: 15, fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Glass back/share button ──────────────────────────────────────────────────

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _GlassBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.40),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.10)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? link;
  const _SectionHeader({required this.title, this.link});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(
            color: _kText, fontSize: 16, fontWeight: FontWeight.w700,
          )),
          if (link != null) Text(link!, style: const TextStyle(
            color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w700,
          )),
        ],
      ),
    );
  }
}

// ─── Match mini card ──────────────────────────────────────────────────────────

class _MatchMiniCard extends StatelessWidget {
  final _MatchUser user;
  const _MatchMiniCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: user.avatarColor.withOpacity(.80),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(user.name[0], style: const TextStyle(
                    color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w800,
                  )),
                ),
              ),
              Positioned(
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1516),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _kGold.withOpacity(.20)),
                  ),
                  child: Text('${user.matchPct}%', style: const TextStyle(
                    color: _kGold, fontSize: 9, fontWeight: FontWeight.w900,
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(user.name, style: const TextStyle(
            color: _kText, fontSize: 12, fontWeight: FontWeight.w700,
          )),
          Text('${user.age}', style: const TextStyle(
            color: _kFaint, fontSize: 10,
          )),
        ],
      ),
    );
  }
}

// ─── Open trip card ───────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  final _OpenTrip trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.title, style: const TextStyle(
                      color: _kText, fontSize: 15,
                      fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 4),
                    Text(trip.dates, style: const TextStyle(
                      color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w600,
                    )),
                  ],
                ),
              ),
              // Spots indicator
              Row(
                children: List.generate(trip.totalSpots, (i) {
                  final filled = i < trip.filledSpots;
                  return Container(
                    width: 20, height: 20,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: filled
                          ? _kTeal.withOpacity(.15)
                          : Colors.white.withOpacity(.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: filled
                            ? _kTeal2
                            : Colors.white.withOpacity(.10),
                        style: filled ? BorderStyle.solid : BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        filled ? '✓' : '+',
                        style: TextStyle(
                          color: filled ? _kTeal2 : _kFaint,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(trip.description, style: const TextStyle(
            color: _kMuted, fontSize: 12, height: 1.4,
          )),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(.10)),
            ),
            child: const Center(
              child: Text('Request to join trip', style: TextStyle(
                color: _kText, fontSize: 13, fontWeight: FontWeight.w700,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pulse dot ────────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat();
    _scale = Tween(begin: 1.0, end: 2.2).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween(begin: 0.6, end: 0.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20, height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kTeal2.withOpacity(_fade.value),
                ),
              ),
            ),
          ),
          Container(
            width: 12, height: 12,
            decoration: const BoxDecoration(
              color: _kTeal2, shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}