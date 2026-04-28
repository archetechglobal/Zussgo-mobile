// lib/features/explore/screens/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/nav_provider.dart';
import '../../home/widgets/home_bottom_nav.dart';
import '../../profile/models/profile_model.dart';
import '../../profile/widgets/user_profile_sheet.dart';
import '../../trips/models/trip_model.dart';
import '../../trips/screens/create_trip_sheet.dart';
import '../providers/explore_provider.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────

const _kBg    = Color(0xFF070E0F);
const _kTeal  = Color(0xFF1EC9B8);
const _kTeal2 = Color(0xFF58DAD0);
const _kGold  = Color(0xFFF7B84E);
const _kText  = Color(0xFFEDF7F4);
const _kMuted = Color(0xFFA8C4BF);
const _kFaint = Color(0xFF6A8882);

// ─── Vibe model (static UI data) ─────────────────────────────────────────────

class _VibeItem {
  final String emoji;
  final String label;
  final Color color;
  final String filter;
  const _VibeItem(this.emoji, this.label, this.color, this.filter);
}

const _vibes = [
  _VibeItem('🌊', 'Beach &\nSocial',     Color(0xFF1EC9B8), 'beach'),
  _VibeItem('🏔️', 'Mountains\n& Trek',   Color(0xFF9FD9BE), 'mountains'),
  _VibeItem('🎪', 'Culture &\nFestivals', Color(0xFFF7B84E), 'culture'),
  _VibeItem('✨', 'Wellness\n& Retreat',  Color(0xFFFFB3C1), 'wellness'),
];

// ─── Destination model (UI/meta only — no hardcoded matches or trips) ─────────

class _Dest {
  final String name;
  final String badge;
  final Color badgeColor;
  final String vibe;
  final String desc;
  final List<String> filters;
  final Color heroColor;
  const _Dest({
    required this.name,
    required this.badge,
    required this.badgeColor,
    required this.vibe,
    required this.desc,
    required this.filters,
    required this.heroColor,
  });
}

final _dests = <_Dest>[
  _Dest(
    name: 'Goa', badge: '🔥 #1 Most Active', badgeColor: _kTeal2,
    vibe: '🌊 Beach & Social',
    desc: 'The ultimate escape. Perfect for weekend parties, beach cafes, and meeting new people.',
    filters: ['beach'], heroColor: const Color(0xFF1C3E40),
  ),
  _Dest(
    name: 'Pushkar', badge: '🎪 Upcoming Festival', badgeColor: _kGold,
    vibe: '🎪 Culture & Festival',
    desc: 'Sacred ghats, desert vibes, and the famous Camel Fair. Culture overload in the best way.',
    filters: ['culture'], heroColor: const Color(0xFF36261A),
  ),
  _Dest(
    name: 'Spiti Valley', badge: '🏔 Adventure Pick', badgeColor: _kTeal2,
    vibe: '🏔 Mountains & Trek',
    desc: 'Raw Himalayas at 14,000ft. Monastery hops, stargazing, and silence that resets you.',
    filters: ['mountains'], heroColor: const Color(0xFF1A2E3A),
  ),
  _Dest(
    name: 'Kerala', badge: '🌿 Trending Now', badgeColor: _kTeal2,
    vibe: '✨ Wellness & Retreat',
    desc: 'Backwaters, Ayurveda, and coffee estates. The slow travel capital of India.',
    filters: ['wellness', 'beach'], heroColor: const Color(0xFF1A2E20),
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

// ─── Feed view ────────────────────────────────────────────────────────────────

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
        ListView(
          padding: EdgeInsets.only(top: top + 72, bottom: navH + 16),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text('Pick your vibe', style: TextStyle(
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
                itemBuilder: (_, i) => _VibeCard(
                  vibe: _vibes[i],
                  active: filter == _vibes[i].filter,
                  onTap: () => onVibeSelect(_vibes[i].filter),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trending this weekend', style: TextStyle(
                    color: _kText, fontSize: 18, fontWeight: FontWeight.w700,
                    letterSpacing: -.2,
                  )),
                  const Text('See all', style: TextStyle(
                    color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w700,
                  )),
                ],
              ),
            ),
            ...dests.map((d) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _HeroCard(dest: d, onTap: () => onDestTap(d)),
            )),
          ],
        ),
        Positioned(
          top: 0, left: 0, right: 0,
          child: _SearchHeader(top: top),
        ),
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
// Uses peopleGoingToProvider to show live avatar stack + traveler count.

class _HeroCard extends ConsumerWidget {
  final _Dest dest;
  final VoidCallback onTap;
  const _HeroCard({required this.dest, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(peopleGoingToProvider(dest.name));
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
                      colors: [Colors.transparent, Colors.black.withOpacity(.88)],
                      stops: const [0.35, 1.0],
                    ),
                  ),
                ),
              ),
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
              Positioned(
                left: 16, right: 16, bottom: 16,
                child: peopleAsync.when(
                  loading: () => _CardBottomSkeleton(name: d.name),
                  error: (_, __) => _CardBottom(
                    name: d.name, people: const [], count: 0),
                  data: (people) => _CardBottom(
                    name: d.name, people: people, count: people.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBottom extends StatelessWidget {
  final String name;
  final List<ProfileModel> people;
  final int count;
  const _CardBottom({
    required this.name, required this.people, required this.count});

  @override
  Widget build(BuildContext context) {
    final preview = people.take(3).toList();
    final extra   = count - preview.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: const TextStyle(
                color: _kText, fontSize: 26,
                fontWeight: FontWeight.w700, letterSpacing: -.3,
              )),
              const SizedBox(height: 4),
              Text(
                count == 0
                    ? 'Be the first to head here'
                    : '$count solo traveler${count == 1 ? '' : 's'} going',
                style: const TextStyle(color: _kMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        if (preview.isNotEmpty)
          _LiveAvatarStack(people: preview, extra: extra > 0 ? extra : 0),
      ],
    );
  }
}

class _CardBottomSkeleton extends StatelessWidget {
  final String name;
  const _CardBottomSkeleton({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: const TextStyle(
                color: _kText, fontSize: 26,
                fontWeight: FontWeight.w700, letterSpacing: -.3,
              )),
              const SizedBox(height: 4),
              Container(
                height: 10, width: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Live avatar stack ────────────────────────────────────────────────────────

class _LiveAvatarStack extends StatelessWidget {
  final List<ProfileModel> people;
  final int extra;
  const _LiveAvatarStack({required this.people, required this.extra});

  Color _colorFor(String? name) {
    const palette = [
      Color(0xFFF7B84E), Color(0xFFFFB3C1), Color(0xFF1EC9B8),
      Color(0xFFB57BFF), Color(0xFF9FD9BE),
    ];
    if (name == null || name.isEmpty) return palette[0];
    return palette[name.codeUnitAt(0) % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final count = people.length;
    return SizedBox(
      height: 28,
      width: count * 20.0 + 32,
      child: Stack(
        children: [
          ...people.asMap().entries.map((e) {
            final p = e.value;
            final initial = (p.name?.isNotEmpty == true)
                ? p.name![0].toUpperCase()
                : '?';
            return Positioned(
              left: e.key * 20.0,
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: _colorFor(p.name).withOpacity(.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0B1516), width: 2),
                ),
                child: Center(
                  child: Text(initial, style: const TextStyle(
                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800,
                  )),
                ),
              ),
            );
          }),
          if (extra > 0)
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

// ─── Detail view (live data) ──────────────────────────────────────────────────

class _DetailView extends ConsumerWidget {
  final _Dest dest;
  final double top, bottom;
  final VoidCallback onBack;
  const _DetailView({
    required this.dest, required this.top,
    required this.bottom, required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = dest;
    final peopleAsync = ref.watch(peopleGoingToProvider(d.name));
    final tripsAsync  = ref.watch(openTripsForProvider(d.name));

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

              // ── Live stats bar ─────────────────────────────────────────
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
                          peopleAsync.when(
                            loading: () => Container(
                              height: 14, width: 160,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            error: (_, __) => const Text(
                              'Travelers active here',
                              style: TextStyle(color: _kText, fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                            data: (people) => Text(
                              people.isEmpty
                                  ? 'Be the first to head here'
                                  : '${people.length} traveler${people.length == 1 ? '' : 's'} active here',
                              style: const TextStyle(
                                color: _kText, fontSize: 15, fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text('High match rate for your vibe',
                              style: TextStyle(color: _kFaint, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── People heading out ─────────────────────────────────────
              _SectionHeader('People heading out here', 'See all'),
              peopleAsync.when(
                loading: () => _HorizontalSkeletonRow(),
                error: (_, __) => _EmptyStateInline(
                    icon: Icons.people_outline_rounded,
                    message: 'Could not load travelers'),
                data: (people) => people.isEmpty
                    ? _EmptyStateInline(
                        icon: Icons.people_outline_rounded,
                        message: 'No travelers heading here yet')
                    : SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: people.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => UserProfileSheet.show(
                                context, name: people[i].name ?? 'Traveler'),
                            child: _LiveMatchCard(profile: people[i]),
                          ),
                        ),
                      ),
              ),

              // ── Open trips to join ─────────────────────────────────────
              _SectionHeader('Open trips to join', null),
              tripsAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: List.generate(2, (_) => const _TripSkeleton()),
                  ),
                ),
                error: (_, __) => _EmptyStateInline(
                    icon: Icons.luggage_rounded,
                    message: 'Could not load trips'),
                data: (trips) => trips.isEmpty
                    ? _EmptyStateInline(
                        icon: Icons.luggage_rounded,
                        message: 'No open trips yet — start one!')
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: trips
                              .map((t) => _LiveTripCard(trip: t))
                              .toList(),
                        ),
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

// ─── Live match card ──────────────────────────────────────────────────────────

class _LiveMatchCard extends StatelessWidget {
  final ProfileModel profile;
  const _LiveMatchCard({required this.profile});

  Color get _color {
    const palette = [
      Color(0xFFF7B84E), Color(0xFFFFB3C1), Color(0xFF1EC9B8),
      Color(0xFFB57BFF), Color(0xFF9FD9BE),
    ];
    final name = profile.name ?? '';
    return name.isEmpty ? palette[0] : palette[name.codeUnitAt(0) % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final initial = (profile.name?.isNotEmpty == true)
        ? profile.name![0].toUpperCase()
        : '?';
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
                  color: _color.withOpacity(.80),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(initial, style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800,
                  )),
                ),
              ),
              // Vibe badge if available
              if (profile.vibes.isNotEmpty)
                Positioned(
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1516),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _kGold.withOpacity(.20)),
                    ),
                    child: Text(
                      profile.vibes.first.length > 8
                          ? '${profile.vibes.first.substring(0, 7)}…'
                          : profile.vibes.first,
                      style: const TextStyle(
                        color: _kGold, fontSize: 8, fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.name ?? 'Traveler',
            style: const TextStyle(
              color: _kText, fontSize: 12, fontWeight: FontWeight.w700,
            ),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          if (profile.age != null)
            Text('${profile.age}',
                style: const TextStyle(color: _kFaint, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── Live trip card ───────────────────────────────────────────────────────────

class _LiveTripCard extends StatelessWidget {
  final TripModel trip;
  const _LiveTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    // Derive a human-readable title from destination + vibe/intent
    final vibeLabel = trip.vibe ?? trip.intent ?? '';
    final title = vibeLabel.isNotEmpty
        ? '${trip.destination} · $vibeLabel'
        : trip.destination;

    // Slot dots: use budget/intent hint for group size or default 4
    const totalSlots = 4;
    // We don't have a slots field yet; show trip as 1 filled (creator), rest open
    const filledSlots = 1;

    final creatorName = trip.creator?.name ?? 'Traveler';

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
                    Text(title, style: const TextStyle(
                      color: _kText, fontSize: 15, fontWeight: FontWeight.w700,
                    ), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(trip.dates, style: const TextStyle(
                      color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w600,
                    )),
                  ],
                ),
              ),
              // Slot dots
              Row(
                children: List.generate(totalSlots, (i) {
                  final filled = i < filledSlots;
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
                      ),
                    ),
                    child: Center(
                      child: Text(filled ? '✓' : '+', style: TextStyle(
                        color: filled ? _kTeal2 : _kFaint, fontSize: 10,
                      )),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Creator byline
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: _kFaint, size: 12),
              const SizedBox(width: 4),
              Text('By $creatorName', style: const TextStyle(
                color: _kFaint, fontSize: 11,
              )),
            ],
          ),
          if (trip.intent?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(trip.intent!, style: const TextStyle(
              color: _kMuted, fontSize: 12, height: 1.4,
            ), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
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

// ─── Skeleton helpers ─────────────────────────────────────────────────────────

class _HorizontalSkeletonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.03),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _TripSkeleton extends StatelessWidget {
  const _TripSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.03),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ─── Empty state inline ───────────────────────────────────────────────────────

class _EmptyStateInline extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyStateInline({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _kFaint, size: 28),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(
              color: _kFaint, fontSize: 13,
            )),
          ],
        ),
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

// ─── Pulse dot ────────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          color: _kTeal.withOpacity(.4 + .6 * _ctrl.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _kTeal.withOpacity(.3 * _ctrl.value),
              blurRadius: 8, spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
