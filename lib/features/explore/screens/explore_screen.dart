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
const _kTeal   = Color(0xFF1EC9B8);
const _kTeal2  = Color(0xFF58DAD0);
const _kGold   = Color(0xFFF7B84E);
const _kText   = Color(0xFFEDF7F4);
const _kMuted  = Color(0xFFA8C4BF);
const _kFaint  = Color(0xFF6A8882);

// ─── Models ───────────────────────────────────────────────────────────────────

class _VibeItem {
  final String emoji;
  final String label;
  final Color color;
  final String filter;
  const _VibeItem(this.emoji, this.label, this.color, this.filter);
}

class _Dest {
  final String name;
  final String badge;
  final Color badgeColor;
  final int count;
  final String vibe;
  final String desc;
  final List<String> filters;
  final Color heroColor;
  final List<_Match> matches;
  final List<_Trip> trips;
  const _Dest({
    required this.name, required this.badge, required this.badgeColor,
    required this.count, required this.vibe, required this.desc,
    required this.filters, required this.heroColor,
    required this.matches, required this.trips,
  });
}

class _Match {
  final String name;
  final int age;
  final int pct;
  final Color color;
  const _Match(this.name, this.age, this.pct, this.color);
}

class _Trip {
  final String title;
  final String dates;
  final String desc;
  final int total;
  final int filled;
  const _Trip(this.title, this.dates, this.desc, this.total, this.filled);
}

// ─── Data ─────────────────────────────────────────────────────────────────────

const _vibes = [
  _VibeItem('🌊', 'Beach &\nSocial',    Color(0xFF1EC9B8), 'beach'),
  _VibeItem('🏔️', 'Mountains\n& Trek',  Color(0xFF9FD9BE), 'mountains'),
  _VibeItem('🎪', 'Culture &\nFestivals',Color(0xFFF7B84E), 'culture'),
  _VibeItem('✨', 'Wellness\n& Retreat', Color(0xFFFFB3C1), 'wellness'),
];

final _dests = <_Dest>[
  _Dest(
    name: 'Goa', badge: '🔥 #1 Most Active', badgeColor: _kTeal2,
    count: 78, vibe: '🌊 Beach & Social',
    desc: 'The ultimate escape. Perfect for weekend parties, beach cafes, and meeting new people.',
    filters: ['beach'], heroColor: const Color(0xFF1C3E40),
    matches: [
      _Match('Meera', 24, 97, Color(0xFFF7B84E)),
      _Match('Priya', 23, 88, Color(0xFFFFB3C1)),
      _Match('Dev',   26, 84, Color(0xFF1EC9B8)),
    ],
    trips: [_Trip('South Goa Chill Weekend', 'May 12–15',
        'Looking for 2 more to split a villa in Palolem. Very laid back vibe.', 4, 2)],
  ),
  _Dest(
    name: 'Pushkar', badge: '🎪 Upcoming Festival', badgeColor: _kGold,
    count: 42, vibe: '🎪 Culture & Festival',
    desc: 'Sacred ghats, desert vibes, and the famous Camel Fair. Culture overload in the best way.',
    filters: ['culture'], heroColor: const Color(0xFF36261A),
    matches: [
      _Match('Anika', 26, 92, Color(0xFFB57BFF)),
      _Match('Sara',  24, 85, Color(0xFF1EC9B8)),
    ],
    trips: [_Trip('Pushkar Festival Group', 'May 18–21',
        'Group of 3 heading for the festival. Need 1 more. Heritage haveli stay.', 4, 3)],
  ),
  _Dest(
    name: 'Spiti Valley', badge: '🏔 Adventure Pick', badgeColor: _kTeal2,
    count: 34, vibe: '🏔 Mountains & Trek',
    desc: 'Raw Himalayas at 14,000ft. Monastery hops, stargazing, and silence that resets you.',
    filters: ['mountains'], heroColor: const Color(0xFF1A2E3A),
    matches: [
      _Match('Arjun', 28, 94, Color(0xFFF7B84E)),
      _Match('Rohan', 27, 88, Color(0xFF1EC9B8)),
    ],
    trips: [_Trip('Spiti 8-Day Circuit', 'May 10–18',
        'Kaza base, Key monastery, Chandratal lake. Self-drive. Looking for 1–2.', 3, 2)],
  ),
  _Dest(
    name: 'Kerala', badge: '🌿 Trending Now', badgeColor: _kTeal2,
    count: 56, vibe: '✨ Wellness & Retreat',
    desc: 'Backwaters, Ayurveda, and coffee estates. The slow travel capital of India.',
    filters: ['wellness', 'beach'], heroColor: const Color(0xFF1A2E20),
    matches: [
      _Match('Priya', 25, 91, Color(0xFF1EC9B8)),
      _Match('Dev',   25, 87, Color(0xFFF7B84E)),
    ],
    trips: [_Trip('Kerala Backwaters 5D', 'May 20–25',
        'Alleppey houseboat + Munnar. Chill group, open to suggestions.', 4, 2)],
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String? _filter;
  _Dest?  _detail;

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

  List<_Dest> get _filtered => _filter == null
      ? _dests
      : _dests.where((d) => d.filters.contains(_filter)).toList();

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final navH   = 88.0 + bottom + 12;

    return Scaffold(
      backgroundColor: _kBg,
      body: _detail != null
          ? _DetailView(
        dest: _detail!,
        top: top, bottom: bottom,
        onBack: () => setState(() => _detail = null),
      )
          : _FeedView(
        top: top, navH: navH, bottom: bottom,
        filter: _filter,
        dests: _filtered,
        onVibeSelect: (f) =>
            setState(() => _filter = _filter == f ? null : f),
        onDestTap: (d) => setState(() => _detail = d),
        nav: const HomeBottomNav(),
      ),
    );
  }
}

// ─── Feed ─────────────────────────────────────────────────────────────────────

class _FeedView extends StatelessWidget {
  final double top, navH, bottom;
  final String? filter;
  final List<_Dest> dests;
  final ValueChanged<String> onVibeSelect;
  final ValueChanged<_Dest> onDestTap;
  final Widget nav;

  const _FeedView({
    required this.top, required this.navH, required this.bottom,
    required this.filter, required this.dests,
    required this.onVibeSelect, required this.onDestTap, required this.nav,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scrollable feed
        ListView(
          padding: EdgeInsets.only(top: top + 72, bottom: navH + 16),
          children: [
            // Vibe section label
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text('Pick your vibe', style: TextStyle(
                color: _kText, fontSize: 18, fontWeight: FontWeight.w700,
                letterSpacing: -.2,
              )),
            ),

            // Vibe horizontal scroll
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _vibes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _VibeCard(
                  vibe: _vibes[i],
                  active: filter == _vibes[i].filter,
                  onTap: () => onVibeSelect(_vibes[i].filter),
                ),
              ),
            ),

            // Trending label
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trending this weekend', style: TextStyle(
                    color: _kText, fontSize: 18, fontWeight: FontWeight.w700,
                    letterSpacing: -.2,
                  )),
                  Text('See all', style: const TextStyle(
                    color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w700,
                  )),
                ],
              ),
            ),

            // Destination cards
            ...dests.map((d) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _HeroCard(dest: d, onTap: () => onDestTap(d)),
            )),
          ],
        ),

        // Sticky header (search bar)
        Positioned(
          top: 0, left: 0, right: 0,
          child: _SearchHeader(top: top),
        ),

        // Bottom nav
        Positioned(
          left: 12, right: 12,
          bottom: 12 + bottom,
          child: nav,
        ),
      ],
    );
  }
}

// ─── Search header ────────────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  final double top;
  const _SearchHeader({required this.top});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 10, 16, 14),
      decoration: BoxDecoration(
        color: _kBg.withOpacity(.94),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(.04)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(.07)),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 12),
                  Icon(Icons.search_rounded, color: _kFaint, size: 17),
                  SizedBox(width: 8),
                  Text('Where to next?', style: TextStyle(
                    color: _kFaint, fontSize: 13,
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _kTeal.withOpacity(.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kTeal.withOpacity(.22)),
            ),
            child: const Icon(Icons.map_outlined, color: _kTeal2, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── Vibe card ────────────────────────────────────────────────────────────────

class _VibeCard extends StatelessWidget {
  final _VibeItem vibe;
  final bool active;
  final VoidCallback onTap;
  const _VibeCard({required this.vibe, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 100, height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [
              vibe.color.withOpacity(active ? .42 : .22),
              const Color(0xFF112425),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? vibe.color.withOpacity(.65)
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
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(.55)],
                  ),
                ),
              ),
            ),
            Positioned(top: 12, right: 12,
                child: Text(vibe.emoji, style: const TextStyle(fontSize: 20))),
            Positioned(left: 12, bottom: 12,
                child: Text(vibe.label, style: const TextStyle(
                  color: _kText, fontSize: 13, fontWeight: FontWeight.w700, height: 1.25,
                ))),
          ],
        ),
      ),
    );
  }
}

// ─── Hero destination card ────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final _Dest dest;
  final VoidCallback onTap;
  const _HeroCard({required this.dest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final d = dest;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(.08)),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(.30),
            blurRadius: 30, offset: const Offset(0, 10),
          )],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hero bg
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [d.heroColor, const Color(0xFF0B1516)],
                  ),
                ),
              ),
              // Bottom dark fade
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(.88)],
                      stops: const [0.35, 1.0],
                    ),
                  ),
                ),
              ),
              // Badge
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
                    color: d.badgeColor, fontSize: 11, fontWeight: FontWeight.w800,
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
                          Text('${d.count} solo travelers going',
                              style: const TextStyle(color: _kMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    _AvatarStack(matches: d.matches, extra: d.count - d.matches.length),
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

// ─── Avatar stack ─────────────────────────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  final List<_Match> matches;
  final int extra;
  const _AvatarStack({required this.matches, required this.extra});

  @override
  Widget build(BuildContext context) {
    final count = matches.length;
    return SizedBox(
      height: 28,
      width: count * 20.0 + 32,
      child: Stack(
        children: [
          ...matches.asMap().entries.map((e) => Positioned(
            left: e.key * 20.0,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: e.value.color.withOpacity(.85),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0B1516), width: 2),
              ),
              child: Center(
                child: Text(e.value.name[0], style: const TextStyle(
                  color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800,
                )),
              ),
            ),
          )),
          Positioned(
            left: count * 20.0,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.10),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0B1516), width: 2),
              ),
              child: Center(
                child: Text('+$extra', style: const TextStyle(
                  color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Destination detail ───────────────────────────────────────────────────────

class _DetailView extends StatelessWidget {
  final _Dest dest;
  final double top, bottom;
  final VoidCallback onBack;
  const _DetailView({
    required this.dest, required this.top,
    required this.bottom, required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final d = dest;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 80 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover ──────────────────────────────────────────────────
              SizedBox(
                height: 300,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [d.heroColor, const Color(0xFF0B1516)],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, const Color(0xFF0B1516)],
                            stops: const [0.40, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Back + share
                    Positioned(
                      top: top + 10, left: 16, right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _GlassBtn(Icons.arrow_back_ios_new_rounded, onBack),
                          _GlassBtn(Icons.ios_share_rounded, () {}),
                        ],
                      ),
                    ),
                    // Info
                    Positioned(
                      left: 16, right: 16, bottom: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kTeal.withOpacity(.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _kTeal.withOpacity(.22)),
                            ),
                            child: Text(d.vibe, style: const TextStyle(
                              color: _kTeal2, fontSize: 10, fontWeight: FontWeight.w800,
                            )),
                          ),
                          const SizedBox(height: 10),
                          Text(d.name, style: const TextStyle(
                            color: _kText, fontSize: 36,
                            fontWeight: FontWeight.w700, letterSpacing: -.4,
                          )),
                          const SizedBox(height: 8),
                          Text(d.desc, style: const TextStyle(
                            color: _kMuted, fontSize: 13, height: 1.5,
                          )),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Live stats ──────────────────────────────────────────────
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
                          Text('${d.count} travelers active here',
                              style: const TextStyle(
                                color: _kText, fontSize: 15, fontWeight: FontWeight.w700,
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
              _SectionHeader('Your top matches going here', 'See all'),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: d.matches.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => UserProfileSheet.show(
                        context, name: d.matches[i].name),
                    child: _MatchCard(m: d.matches[i]),
                  ),
                ),
              ),

              // ── Open trips ──────────────────────────────────────────────
              _SectionHeader('Open trips to join', null),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: d.trips.map((t) => _TripCard(trip: t, dest: d.name)).toList(),
                ),
              ),
            ],
          ),
        ),

        // ── Sticky CTA ──────────────────────────────────────────────────
        Positioned(
          left: 12, right: 12, bottom: 12 + bottom,
          child: GestureDetector(
            onTap: () => CreateTripSheet.show(context),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_kTeal2, _kTeal]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                  color: _kTeal.withOpacity(.28),
                  blurRadius: 32, offset: const Offset(0, 16),
                )],
              ),
              child: Center(
                child: Text('Plan a trip to ${d.name}',
                    style: const TextStyle(
                      color: Color(0xFF041818),
                      fontSize: 15, fontWeight: FontWeight.w800,
                    )),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Glass button ─────────────────────────────────────────────────────────────

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassBtn(this.icon, this.onTap);

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
  const _SectionHeader(this.title, this.link);

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
          if (link != null)
            Text(link!, style: const TextStyle(
              color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w700,
            )),
        ],
      ),
    );
  }
}

// ─── Match card ───────────────────────────────────────────────────────────────

class _MatchCard extends StatelessWidget {
  final _Match m;
  const _MatchCard({required this.m});

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
                  color: m.color.withOpacity(.80),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(m.name[0], style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800,
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
                  child: Text('${m.pct}%', style: const TextStyle(
                    color: _kGold, fontSize: 9, fontWeight: FontWeight.w900,
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(m.name, style: const TextStyle(
            color: _kText, fontSize: 12, fontWeight: FontWeight.w700,
          )),
          Text('${m.age}', style: const TextStyle(color: _kFaint, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── Trip card ────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  final _Trip trip;
  final String dest;
  const _TripCard({required this.trip, required this.dest});

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
                      color: _kText, fontSize: 15, fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 4),
                    Text(trip.dates, style: const TextStyle(
                      color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w600,
                    )),
                  ],
                ),
              ),
              Row(
                children: List.generate(trip.total, (i) {
                  final filled = i < trip.filled;
                  return Container(
                    width: 20, height: 20,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: filled ? _kTeal.withOpacity(.15) : Colors.white.withOpacity(.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: filled ? _kTeal2 : Colors.white.withOpacity(.10),
                      ),
                    ),
                    child: Center(
                      child: Text(filled ? '✓' : '+',
                          style: TextStyle(
                            color: filled ? _kTeal2 : _kFaint, fontSize: 10,
                          )),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(trip.desc, style: const TextStyle(
            color: _kMuted, fontSize: 12, height: 1.4,
          )),
          const SizedBox(height: 14),
          Container(
            width: double.infinity, height: 42,
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
  late final Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat();
    _scale = Tween(begin: 1.0, end: 2.2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade  = Tween(begin: 0.6, end: 0.0).animate(_ctrl);
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
            decoration: const BoxDecoration(color: _kTeal2, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}