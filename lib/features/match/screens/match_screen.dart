// lib/features/match/screens/match_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/nav_provider.dart';
import '../../home/widgets/home_bottom_nav.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final String initialTab;
  const MatchScreen({super.key, this.initialTab = 'discover'});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  late int _tab;
  int _activeChip = 0;

  // ── Palette ────────────────────────────────────────────────────────────────
  static const bg    = Color(0xFF070E0F);
  static const text  = Color(0xFFEDF7F4);
  static const muted = Color(0xFFA8C4BF);
  static const faint = Color(0xFF6A8882);
  static const teal  = Color(0xFF1EC9B8);
  static const teal2 = Color(0xFF58DAD0);
  static const gold  = Color(0xFFF7B84E);
  static const rose  = Color(0xFFFFB3C1);

  // ── Mock data ──────────────────────────────────────────────────────────────
  final List<String> _chips = [
    'All matches', 'Next 7 days', 'Women only', 'Under ₹15k', 'Budget',
  ];

  final List<_TravelerData> _travelers = const [
    _TravelerData(name: 'Meera',  age: 24, city: 'Pune',      vibe: '🏔 Adventure', score: 97, scoreColor: 'gold', variant: 1),
    _TravelerData(name: 'Kabir',  age: 26, city: 'Mumbai',    vibe: '🎉 Festival',  score: 94, scoreColor: 'teal', variant: 2),
    _TravelerData(name: 'Anika',  age: 23, city: 'Delhi',     vibe: '☕ Chill',     score: 91, scoreColor: 'teal', variant: 3),
    _TravelerData(name: 'Dev',    age: 25, city: 'Bangalore', vibe: '🥾 Trekking', score: 89, scoreColor: 'gold', variant: 4),
    _TravelerData(name: 'Priya',  age: 22, city: 'Chennai',   vibe: '🌊 Beach',    score: 86, scoreColor: 'teal', variant: 1),
    _TravelerData(name: 'Rohan',  age: 27, city: 'Hyderabad', vibe: '🎸 Party',    score: 83, scoreColor: 'gold', variant: 2),
    _TravelerData(name: 'Sara',   age: 24, city: 'Jaipur',    vibe: '🏛 Culture',  score: 81, scoreColor: 'teal', variant: 3),
    _TravelerData(name: 'Arjun',  age: 28, city: 'Kolkata',   vibe: '📸 Photo',    score: 78, scoreColor: 'gold', variant: 4),
  ];

  final List<_RequestData> _requests = const [
    _RequestData(
      name: 'Priya S.',
      tripLabel: 'wants to join your Goa trip',
      dates: 'May 12–15 · 3 days',
      timeAgo: 'Requested 2 hours ago',
      compatibility: '97% · Top Match',
      compatibilityHigh: true,
      vibe: 'Both want Chill',
      budget: 'Same · Under ₹15k',
      verified: true,
      avatarVariant: 'gold',
    ),
    _RequestData(
      name: 'Rohan K.',
      tripLabel: 'wants to join your Goa trip',
      dates: 'May 12–15 · 3 days',
      timeAgo: 'Requested yesterday',
      compatibility: '82% · Good Match',
      compatibilityHigh: false,
      vibe: 'Party ≠ You Chill',
      budget: 'Similar · Under ₹20k',
      verified: false,
      avatarVariant: 'rose',
    ),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab == 'requests' ? 1 : 0;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    // Sync bottom nav highlight to Match (index 2)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bottomNavIndexProvider.notifier).setIndex(2);
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Same nav bar height as HomeScreen
    final bottomNavHeight = 88.0 + bottomInset;

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      body: Stack(
        children: [
          // ── Background gradient ────────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.7, -1),
                  radius: 1.2,
                  colors: [Color(0x281EC9B8), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            bottom: bottomNavHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topInset + 10),

                // Title row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Back → Home
                      GestureDetector(
                        onTap: () {
                          ref.read(bottomNavIndexProvider.notifier).setIndex(0);
                          context.go('/home');
                        },
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(.08)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: teal2, size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Match',
                          style: TextStyle(
                            color: text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.03,
                          ),
                        ),
                      ),
                      // Filter
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: teal.withOpacity(.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: teal.withOpacity(.22)),
                        ),
                        child: const Icon(Icons.tune_rounded, color: teal2, size: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Discover / Requests toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.04),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white.withOpacity(.05)),
                    ),
                    child: Row(
                      children: [
                        _ToggleBtn(
                          label: 'Discover',
                          active: _tab == 0,
                          badgeCount: 0,
                          onTap: () => setState(() => _tab = 0),
                        ),
                        _ToggleBtn(
                          label: 'Requests',
                          active: _tab == 1,
                          badgeCount: 2,
                          onTap: () => setState(() => _tab = 1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _tab == 0
                        ? _DiscoverView(
                      key: const ValueKey('discover'),
                      chips: _chips,
                      activeChip: _activeChip,
                      onChipTap: (i) => setState(() => _activeChip = i),
                      travelers: _travelers,
                      bottomInset: bottomInset,
                    )
                        : _RequestsView(
                      key: const ValueKey('requests'),
                      requests: _requests,
                      bottomInset: bottomInset,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom nav bar (same as HomeScreen) ───────────────────────────
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

// ─── Toggle button ────────────────────────────────────────────────────────────

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final int badgeCount;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.badgeCount,
    required this.onTap,
  });

  static const text  = Color(0xFFEDF7F4);
  static const faint = Color(0xFF6A8882);
  static const gold  = Color(0xFFF7B84E);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 40,
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? text : faint,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Color(0xFF041818),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Discover view ────────────────────────────────────────────────────────────

class _DiscoverView extends StatelessWidget {
  final List<String> chips;
  final int activeChip;
  final ValueChanged<int> onChipTap;
  final List<_TravelerData> travelers;
  final double bottomInset;

  const _DiscoverView({
    super.key,
    required this.chips,
    required this.activeChip,
    required this.onChipTap,
    required this.travelers,
    required this.bottomInset,
  });

  static const text = Color(0xFFEDF7F4);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final active = i == activeChip;
              return GestureDetector(
                onTap: () => onChipTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? text : Colors.white.withOpacity(.04),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: active ? Colors.transparent : Colors.white.withOpacity(.08),
                    ),
                  ),
                  child: Text(
                    chips[i],
                    style: TextStyle(
                      color: active ? const Color(0xFF041818) : text,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // 2-column grid — NO extra bottom padding needed, parent Positioned handles it
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3 / 4,
            ),
            itemCount: travelers.length,
            itemBuilder: (_, i) => _TravelerCardWidget(data: travelers[i]),
          ),
        ),
      ],
    );
  }
}

// ─── Requests view ────────────────────────────────────────────────────────────

class _RequestsView extends StatelessWidget {
  final List<_RequestData> requests;
  final double bottomInset;

  const _RequestsView({
    super.key,
    required this.requests,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => _RequestCard(data: requests[i]),
    );
  }
}

// ─── Request card ─────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final _RequestData data;
  const _RequestCard({required this.data});

  static const text  = Color(0xFFEDF7F4);
  static const muted = Color(0xFFA8C4BF);
  static const faint = Color(0xFF6A8882);
  static const teal  = Color(0xFF1EC9B8);
  static const teal2 = Color(0xFF58DAD0);
  static const gold  = Color(0xFFF7B84E);
  static const rose  = Color(0xFFFFB3C1);

  Color get _avatarColor {
    switch (data.avatarVariant) {
      case 'gold': return gold;
      case 'rose': return rose;
      default:     return teal2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50, height: 50,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0, right: 0,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: _avatarColor.withOpacity(.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF0B1516), width: 2),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, left: 0,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF0B1516), width: 2),
                        ),
                        child: const Center(
                          child: Text('A',
                            style: TextStyle(
                              color: Color(0xFF041818),
                              fontSize: 14, fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.name} ${data.tripLabel}',
                      style: const TextStyle(
                        color: text, fontSize: 15,
                        fontWeight: FontWeight.w700, height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(data.dates, style: const TextStyle(color: muted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(data.timeAgo, style: const TextStyle(color: faint, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(.03)),
            ),
            child: Column(
              children: [
                _StatRow(
                  label: 'Compatibility',
                  value: data.compatibility,
                  valueColor: data.compatibilityHigh ? gold : text,
                ),
                const _StatDivider(),
                _StatRow(
                  label: 'Travel Vibe',
                  value: data.vibe,
                  valueColor: data.compatibilityHigh ? teal2 : rose,
                ),
                const _StatDivider(),
                _StatRow(label: 'Budget', value: data.budget, valueColor: teal2),
                if (data.verified) ...[
                  const _StatDivider(),
                  _StatRow(label: 'Safety', value: 'ID Verified ✓', valueColor: teal2),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: data.compatibilityHigh
                        ? const LinearGradient(colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)])
                        : null,
                    color: data.compatibilityHigh ? null : Colors.white.withOpacity(.05),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: data.compatibilityHigh
                        ? [BoxShadow(
                      color: teal.withOpacity(.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    )]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'Accept ${data.name.split(' ').first}',
                      style: TextStyle(
                        color: data.compatibilityHigh ? const Color(0xFF041818) : text,
                        fontSize: 14, fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: rose.withOpacity(.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: rose.withOpacity(.12)),
                ),
                child: const Icon(Icons.close_rounded, color: rose, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _StatRow({required this.label, required this.value, required this.valueColor});
  static const faint = Color(0xFF6A8882);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: faint, fontSize: 12)),
      Text(value, style: TextStyle(color: valueColor, fontSize: 12, fontWeight: FontWeight.w700)),
    ],
  );
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(vertical: 6),
    color: Colors.white.withOpacity(.05),
  );
}

// ─── Traveler card ────────────────────────────────────────────────────────────

class _TravelerCardWidget extends StatelessWidget {
  final _TravelerData data;
  const _TravelerCardWidget({required this.data});

  static const text  = Color(0xFFEDF7F4);
  static const teal2 = Color(0xFF58DAD0);
  static const gold  = Color(0xFFF7B84E);

  static const List<List<Color>> _gradients = [
    [Color(0xFF1E4044), Color(0xFF112425)],
    [Color(0xFF1A342C), Color(0xFF112425)],
    [Color(0xFF36261A), Color(0xFF112425)],
    [Color(0xFF301E28), Color(0xFF112425)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors     = _gradients[(data.variant - 1) % 4];
    final scoreColor = data.scoreColor == 'teal' ? teal2 : gold;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(.82)],
                stops: const [0.38, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xB20A1213),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(.10)),
              ),
              child: Text(
                '${data.score}%',
                style: TextStyle(color: scoreColor, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Positioned(
            left: 12, right: 12, bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(data.name,
                      style: const TextStyle(
                        color: text, fontSize: 15,
                        fontWeight: FontWeight.w700, height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 13, height: 13,
                      decoration: const BoxDecoration(color: Color(0xFF58DAD0), shape: BoxShape.circle),
                      child: const Center(
                        child: Text('✓',
                          style: TextStyle(color: Colors.black, fontSize: 7, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.age} · ${data.city}',
                  style: TextStyle(color: Colors.white.withOpacity(.70), fontSize: 11),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(data.vibe,
                      style: const TextStyle(color: text, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data models ──────────────────────────────────────────────────────────────

class _TravelerData {
  final String name;
  final int age;
  final String city;
  final String vibe;
  final int score;
  final String scoreColor;
  final int variant;
  const _TravelerData({
    required this.name, required this.age, required this.city,
    required this.vibe, required this.score,
    required this.scoreColor, required this.variant,
  });
}

class _RequestData {
  final String name;
  final String tripLabel;
  final String dates;
  final String timeAgo;
  final String compatibility;
  final bool compatibilityHigh;
  final String vibe;
  final String budget;
  final bool verified;
  final String avatarVariant;
  const _RequestData({
    required this.name, required this.tripLabel, required this.dates,
    required this.timeAgo, required this.compatibility,
    required this.compatibilityHigh, required this.vibe,
    required this.budget, required this.verified, required this.avatarVariant,
  });
}