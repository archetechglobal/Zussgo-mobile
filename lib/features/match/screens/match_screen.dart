// lib/features/match/screens/match_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/nav_provider.dart';
import '../../home/widgets/home_bottom_nav.dart';
import '../../profile/widgets/user_profile_sheet.dart';
import '../../trips/screens/create_trip_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../profile/providers/profile_provider.dart';
import '../../trips/providers/trips_provider.dart';
import '../../trips/models/trip_model.dart';
import '../../connections/providers/connections_provider.dart';
import '../services/match_score_service.dart';
import '../widgets/match_score_badge.dart';

// ---------------------------------------------------------------------------
// Filter state
// ---------------------------------------------------------------------------

class _FilterState {
  final String? vibe;
  final String? gender;
  final int? maxBudget;
  final bool nextWeekOnly;

  const _FilterState({
    this.vibe,
    this.gender,
    this.maxBudget,
    this.nextWeekOnly = false,
  });

  _FilterState copyWith({
    Object? vibe = _sentinel,
    Object? gender = _sentinel,
    Object? maxBudget = _sentinel,
    bool? nextWeekOnly,
  }) =>
      _FilterState(
        vibe: vibe == _sentinel ? this.vibe : vibe as String?,
        gender: gender == _sentinel ? this.gender : gender as String?,
        maxBudget:
            maxBudget == _sentinel ? this.maxBudget : maxBudget as int?,
        nextWeekOnly: nextWeekOnly ?? this.nextWeekOnly,
      );

  bool get isActive =>
      vibe != null || gender != null || maxBudget != null || nextWeekOnly;

  int get activeCount {
    int c = 0;
    if (vibe != null) c++;
    if (gender != null) c++;
    if (maxBudget != null) c++;
    if (nextWeekOnly) c++;
    return c;
  }
}

const _sentinel = Object();

// ---------------------------------------------------------------------------
// MatchScreen
// ---------------------------------------------------------------------------

class MatchScreen extends ConsumerStatefulWidget {
  final String initialTab;
  const MatchScreen({super.key, this.initialTab = 'discover'});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  late int _tab;
  int _activeChip = 0;
  _FilterState _filter = const _FilterState();

  static const bg    = Color(0xFF070E0F);
  static const text  = Color(0xFFEDF7F4);
  static const muted = Color(0xFFA8C4BF);
  static const faint = Color(0xFF6A8882);
  static const teal  = Color(0xFF1EC9B8);
  static const teal2 = Color(0xFF58DAD0);
  static const gold  = Color(0xFFF7B84E);
  static const rose  = Color(0xFFFFB3C1);

  final List<String> _chips = [
    'All matches',
    'Next 7 days',
    'Women only',
    'Under ₹15k',
    'Budget',
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

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab == 'requests' ? 1 : 0;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bottomNavIndexProvider.notifier).setIndex(2);
    });
  }

  void _openFilterSheet() async {
    final result = await showModalBottomSheet<_FilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MatchFilterSheet(current: _filter),
    );
    if (result != null) {
      setState(() => _filter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset      = MediaQuery.of(context).padding.top;
    final bottomInset   = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 88.0 + bottomInset;

    final pendingRequests = ref.watch(tripPendingRequestsProvider);
    final pendingCount    = pendingRequests.asData?.value.length ?? 0;

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      body: Stack(
        children: [
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: bottomNavHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topInset + 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref.read(bottomNavIndexProvider.notifier).setIndex(0);
                          context.go('/home');
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(.08),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: teal2,
                            size: 15,
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
                      GestureDetector(
                        onTap: _openFilterSheet,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _filter.isActive
                                    ? teal.withOpacity(.25)
                                    : teal.withOpacity(.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _filter.isActive
                                      ? teal.withOpacity(.55)
                                      : teal.withOpacity(.22),
                                ),
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: teal2,
                                size: 16,
                              ),
                            ),
                            if (_filter.isActive)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: teal,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${_filter.activeCount}',
                                      style: const TextStyle(
                                        color: Color(0xFF041818),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                          badgeCount: pendingCount,
                          onTap: () => setState(() => _tab = 1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _tab == 0
                        ? _DiscoverView(
                            key: const ValueKey('discover'),
                            chips: _chips,
                            activeChip: _activeChip,
                            onChipTap: (i) => setState(() => _activeChip = i),
                            bottomInset: bottomInset,
                            filter: _filter,
                          )
                        : _LiveRequestsView(
                            key: const ValueKey('requests'),
                            requestsAsync: pendingRequests,
                            bottomInset: bottomInset,
                          ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 88 + bottomInset + 20,
            child: _CreateTripFab(),
          ),
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

// ---------------------------------------------------------------------------
// _MatchFilterSheet
// ---------------------------------------------------------------------------

class _MatchFilterSheet extends StatefulWidget {
  final _FilterState current;
  const _MatchFilterSheet({required this.current});

  @override
  State<_MatchFilterSheet> createState() => _MatchFilterSheetState();
}

class _MatchFilterSheetState extends State<_MatchFilterSheet> {
  late _FilterState _draft;

  static const bg2   = Color(0xFF0D1A1C);
  static const text  = Color(0xFFEDF7F4);
  static const muted = Color(0xFFA8C4BF);
  static const faint = Color(0xFF6A8882);
  static const teal  = Color(0xFF1EC9B8);
  static const teal2 = Color(0xFF58DAD0);

  static const _vibes = [
    '✈️ Adventure',
    '🏖️ Beach',
    '🌄 Backpacking',
    '🍹 Party',
    '🧘 Chill',
    '🏙️ City Explorer',
    '📸 Photography',
    '🍜 Foodie',
  ];

  static const _budgets = [
    _BudgetOption('Under ₹15k', 15000),
    _BudgetOption('Under ₹30k', 30000),
    _BudgetOption('Under ₹50k', 50000),
    _BudgetOption('Any Budget', null),
  ];

  @override
  void initState() {
    super.initState();
    _draft = widget.current;
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(label,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            )),
      );

  Widget _chip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? teal.withOpacity(.18) : Colors.white.withOpacity(.04),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? teal.withOpacity(.55) : Colors.white.withOpacity(.08),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? teal2 : text.withOpacity(.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filter Matches',
                    style: TextStyle(
                      color: text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_draft.isActive)
                  GestureDetector(
                    onTap: () => setState(() => _draft = const _FilterState()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.06),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'Reset all',
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('DATE'),
                  _chip(
                    label: '📅 Next 7 days only',
                    active: _draft.nextWeekOnly,
                    onTap: () => setState(() => _draft = _draft.copyWith(nextWeekOnly: !_draft.nextWeekOnly)),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('TRAVELER GENDER'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(
                        label: '👥 All travelers',
                        active: _draft.gender == null,
                        onTap: () => setState(() => _draft = _draft.copyWith(gender: null)),
                      ),
                      _chip(
                        label: '👩 Women only',
                        active: _draft.gender == 'women',
                        onTap: () => setState(() => _draft = _draft.copyWith(
                            gender: _draft.gender == 'women' ? null : 'women')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('BUDGET'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _budgets
                        .map((b) => _chip(
                              label: b.label,
                              active: _draft.maxBudget == b.max,
                              onTap: () => setState(() => _draft = _draft.copyWith(
                                  maxBudget: _draft.maxBudget == b.max ? null : b.max)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('TRAVEL VIBE'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _vibes
                        .map((v) => _chip(
                              label: v,
                              active: _draft.vibe == v,
                              onTap: () => setState(() => _draft = _draft.copyWith(
                                  vibe: _draft.vibe == v ? null : v)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 20),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(_draft),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: teal.withOpacity(.30),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _draft.isActive
                        ? 'Apply ${_draft.activeCount} filter${_draft.activeCount > 1 ? 's' : ''}'
                        : 'Show all matches',
                    style: const TextStyle(
                      color: Color(0xFF041818),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
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

class _BudgetOption {
  final String label;
  final int? max;
  const _BudgetOption(this.label, this.max);
}

// ---------------------------------------------------------------------------
// _ToggleBtn
// ---------------------------------------------------------------------------

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

  static const _teal = Color(0xFF1EC9B8);
  static const _dark = Color(0xFF041818);
  static const _text = Color(0xFFEDF7F4);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 38,
          decoration: BoxDecoration(
            color: active ? _teal : Colors.transparent,
            borderRadius: BorderRadius.circular(96),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? _dark : _text.withOpacity(.55),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: active
                        ? _dark.withOpacity(.25)
                        : _teal.withOpacity(.20),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: active ? _dark : _teal,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
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

// ---------------------------------------------------------------------------
// Filter logic
// ---------------------------------------------------------------------------

bool _tripPassesFilter(TripModel trip, int chipIndex, _FilterState filter) {
  switch (chipIndex) {
    case 0:
      break;
    case 1:
      final now    = DateTime.now();
      final cutoff = now.add(const Duration(days: 7));
      final dateStr = trip.dates.trim();
      DateTime? startDate;
      final isoMatch = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(dateStr);
      if (isoMatch != null) startDate = DateTime.tryParse(isoMatch.group(1)!);
      startDate ??= trip.createdAt;
      if (!(startDate.isAfter(now.subtract(const Duration(days: 1))) &&
          startDate.isBefore(cutoff))) return false;
      break;
    case 2:
      final creatorVibes = (trip.creator?.vibes ?? []).map((v) => v.toLowerCase()).toList();
      final tripVibe = (trip.vibe ?? '').toLowerCase();
      const femaleHints = ['women', 'girl', 'female', 'ladies', 'she/her'];
      if (!femaleHints.any((h) =>
          creatorVibes.any((v) => v.contains(h)) || tripVibe.contains(h))) return false;
      break;
    case 3:
      final budget = (trip.budget ?? trip.creator?.budget ?? '').toLowerCase();
      if (!(budget.contains('15k') || budget.contains('15,000') ||
          budget.contains('budget') || budget.contains('low') ||
          budget.contains('cheap') || budget.contains('backpack'))) {
        final numMatch = RegExp(r'(\d[\d,]*)').firstMatch(budget);
        if (numMatch != null) {
          final amount = int.tryParse(numMatch.group(1)!.replaceAll(',', '')) ?? 99999;
          if (amount > 15000) return false;
        } else {
          return false;
        }
      }
      break;
    case 4:
      final budget = (trip.budget ?? trip.creator?.budget ?? '').toLowerCase();
      if (!(budget.contains('budget') || budget.contains('low') ||
          budget.contains('cheap') || budget.contains('backpack') ||
          budget.contains('economy'))) {
        final numMatch = RegExp(r'(\d[\d,]*)').firstMatch(budget);
        if (numMatch != null) {
          final amount = int.tryParse(numMatch.group(1)!.replaceAll(',', '')) ?? 99999;
          if (amount > 30000) return false;
        } else {
          return false;
        }
      }
      break;
    default:
      break;
  }

  if (filter.nextWeekOnly) {
    final now    = DateTime.now();
    final cutoff = now.add(const Duration(days: 7));
    final dateStr = trip.dates.trim();
    DateTime? startDate;
    final isoMatch = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(dateStr);
    if (isoMatch != null) startDate = DateTime.tryParse(isoMatch.group(1)!);
    startDate ??= trip.createdAt;
    if (!(startDate.isAfter(now.subtract(const Duration(days: 1))) &&
        startDate.isBefore(cutoff))) return false;
  }

  if (filter.gender == 'women') {
    final creatorVibes = (trip.creator?.vibes ?? []).map((v) => v.toLowerCase()).toList();
    final tripVibe = (trip.vibe ?? '').toLowerCase();
    const femaleHints = ['women', 'girl', 'female', 'ladies', 'she/her'];
    if (!femaleHints.any((h) =>
        creatorVibes.any((v) => v.contains(h)) || tripVibe.contains(h))) return false;
  }

  if (filter.maxBudget != null) {
    final budget = (trip.budget ?? trip.creator?.budget ?? '').toLowerCase();
    final numMatch = RegExp(r'(\d[\d,]*)').firstMatch(budget);
    if (numMatch != null) {
      final amount = int.tryParse(numMatch.group(1)!.replaceAll(',', '')) ?? 99999;
      if (amount > filter.maxBudget!) return false;
    }
  }

  if (filter.vibe != null) {
    final vibeKey = filter.vibe!
        .replaceAll(RegExp(r'[^\w\s]', unicode: true), '').trim().toLowerCase();
    final tripVibe = (trip.vibe ?? '').toLowerCase();
    final creatorVibes = (trip.creator?.vibes ?? []).map((v) => v.toLowerCase()).toList();
    if (!tripVibe.contains(vibeKey) && !creatorVibes.any((v) => v.contains(vibeKey))) return false;
  }

  return true;
}

// ---------------------------------------------------------------------------
// _DiscoverView
// ---------------------------------------------------------------------------

class _DiscoverView extends ConsumerWidget {
  final List<String> chips;
  final int activeChip;
  final ValueChanged<int> onChipTap;
  final double bottomInset;
  final _FilterState filter;

  const _DiscoverView({
    super.key,
    required this.chips,
    required this.activeChip,
    required this.onChipTap,
    required this.bottomInset,
    required this.filter,
  });

  static const text = Color(0xFFEDF7F4);
  static const teal = Color(0xFF1EC9B8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync   = ref.watch(activeTripsProvider);
    final profileAsync = ref.watch(profileProvider);
    final viewer       = profileAsync.asData?.value;

    return tripsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1EC9B8), strokeWidth: 2),
      ),
      error: (e, _) => const Center(
        child: Text('Could not load trips', style: TextStyle(color: Color(0xFF6A8882))),
      ),
      data: (allTrips) {
        final filtered = allTrips
            .where((t) => _tripPassesFilter(t, activeChip, filter))
            .toList();

        return Column(
          children: [
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
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 12),
                          Text(
                            activeChip == 0 && !filter.isActive
                                ? 'No trips available right now'
                                : 'No matches for this filter',
                            style: const TextStyle(
                              color: Color(0xFFEDF7F4),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try a different filter or check back soon',
                            style: TextStyle(color: Color(0xFF6A8882), fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => _TravelerCardWidget(
                        data: _TravelerData(
                          id:        filtered[i].id,
                          name:      filtered[i].creator?.name ?? 'Traveler',
                          age:       filtered[i].creator?.age ?? 0,
                          city:      filtered[i].creator?.baseCity ?? '',
                          vibe:      filtered[i].vibe ?? '✈️ Traveler',
                          rating:    filtered[i].creator?.rating ?? 0,
                          avatarUrl: filtered[i].creator?.avatarUrl,
                          vibes:     filtered[i].creator?.vibes ?? [],
                          variant:   (filtered[i].hashCode % 4) + 1,
                        ),
                        trip:   filtered[i],
                        viewer: viewer,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _LiveRequestsView
// ---------------------------------------------------------------------------

class _LiveRequestsView extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> requestsAsync;
  final double bottomInset;

  const _LiveRequestsView({
    super.key,
    required this.requestsAsync,
    required this.bottomInset,
  });

  static const text  = Color(0xFFEDF7F4);
  static const muted = Color(0xFFA8C4BF);
  static const faint = Color(0xFF6A8882);
  static const teal2 = Color(0xFF58DAD0);

  @override
  Widget build(BuildContext context) {
    return requestsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1EC9B8), strokeWidth: 2),
      ),
      error: (e, _) => const Center(
        child: Text('Could not load requests', style: TextStyle(color: Color(0xFF6A8882))),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🎒', style: TextStyle(fontSize: 40)),
                SizedBox(height: 12),
                Text('No pending requests',
                    style: TextStyle(
                      color: Color(0xFFEDF7F4),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(height: 6),
                Text(
                  'Create a trip to start getting companion requests',
                  style: TextStyle(color: Color(0xFF6A8882), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) => _LiveRequestCard(request: requests[i]),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _LiveRequestCard
// ---------------------------------------------------------------------------

class _LiveRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  const _LiveRequestCard({required this.request});

  static const text  = Color(0xFFEDF7F4);
  static const muted = Color(0xFFA8C4BF);
  static const faint = Color(0xFF6A8882);
  static const teal  = Color(0xFF1EC9B8);
  static const teal2 = Color(0xFF58DAD0);

  @override
  Widget build(BuildContext context) {
    final requester = request['requester'] as Map<String, dynamic>? ?? {};
    final trip      = request['trip']      as Map<String, dynamic>? ?? {};
    final name      = requester['name']    as String? ?? 'Someone';
    final tripName  = trip['destination']  as String? ?? 'your trip';
    final dates     = trip['dates']        as String? ?? '';
    final avatarUrl = requester['avatar_url'] as String?;
    final rating    = (requester['rating'] as num?)?.toDouble() ?? 0;
    final createdAt = request['created_at'] as String?;
    final timeAgo   = createdAt != null
        ? timeago.format(DateTime.parse(createdAt), locale: 'en_short')
        : '';

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
              _LiveAvatar(url: avatarUrl, initial: name[0].toUpperCase()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$name wants to join your $tripName trip',
                        style: const TextStyle(
                          color: text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        )),
                    if (dates.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(dates, style: const TextStyle(color: muted, fontSize: 12)),
                    ],
                    if (timeAgo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Requested $timeAgo',
                          style: const TextStyle(color: faint, fontSize: 10)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (rating > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('★ ${rating.toStringAsFixed(1)} rating',
                  style: const TextStyle(color: Color(0xFFF7B84E), fontSize: 12)),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(.08)),
                    ),
                    child: const Center(
                        child: Text('Decline',
                            style: TextStyle(
                              color: muted,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                        child: Text('Accept',
                            style: TextStyle(
                              color: Color(0xFF041818),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _LiveAvatar
// ---------------------------------------------------------------------------

class _LiveAvatar extends StatelessWidget {
  final String? url;
  final String initial;
  const _LiveAvatar({this.url, required this.initial});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: url!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1EC9B8).withOpacity(.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
            child: Text(initial,
                style: const TextStyle(
                  color: Color(0xFF58DAD0),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ))),
      );
}

// ---------------------------------------------------------------------------
// _TravelerData
// ---------------------------------------------------------------------------

class _TravelerData {
  final String id;
  final String name;
  final int age;
  final String city;
  final String vibe;
  final double rating;
  final String? avatarUrl;
  final List<String> vibes;
  final int variant;

  const _TravelerData({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.vibe,
    required this.rating,
    this.avatarUrl,
    required this.vibes,
    required this.variant,
  });
}

// ---------------------------------------------------------------------------
// _TravelerCardWidget — unchanged design, score badge overlaid on top
// ---------------------------------------------------------------------------

class _TravelerCardWidget extends StatelessWidget {
  final _TravelerData data;
  final TripModel trip;
  final dynamic viewer; // ProfileModel? — dynamic to avoid hard import cycle

  const _TravelerCardWidget({
    super.key,
    required this.data,
    required this.trip,
    required this.viewer,
  });

  static const bg2   = Color(0xFF0D1A1C);
  static const text  = Color(0xFFEDF7F4);
  static const muted = Color(0xFFA8C4BF);
  static const faint = Color(0xFF6A8882);
  static const teal  = Color(0xFF1EC9B8);
  static const teal2 = Color(0xFF58DAD0);
  static const gold  = Color(0xFFF7B84E);

  Color get _variantColor {
    switch (data.variant) {
      case 1: return teal;
      case 2: return gold;
      case 3: return const Color(0xFFFFB3C1);
      default: return teal2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Original card design — completely untouched ──────────────────
        Container(
          decoration: BoxDecoration(
            color: bg2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar area
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: _variantColor.withOpacity(.12),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: data.avatarUrl != null && data.avatarUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: CachedNetworkImage(
                            imageUrl: data.avatarUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (_, __, ___) => _avatarFallback(),
                          ),
                        )
                      : _avatarFallback(),
                ),
              ),
              // Info area
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.age > 0 ? '${data.name}, ${data.age}' : data.name,
                        style: const TextStyle(
                          color: text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (data.city.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          data.city,
                          style: const TextStyle(color: muted, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _variantColor.withOpacity(.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data.vibe,
                          style: TextStyle(
                            color: _variantColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Score badge — overlaid top-left, only if viewer is loaded ────
        if (viewer != null)
          Positioned(
            top: 8,
            left: 8,
            child: MatchScoreBadge(
              viewer: viewer,
              trip: trip,
            ),
          ),
      ],
    );
  }

  Widget _avatarFallback() => Center(
        child: Text(
          data.name.isNotEmpty ? data.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: _variantColor,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// _CreateTripFab
// ---------------------------------------------------------------------------

class _CreateTripFab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const CreateTripSheet(),
      ),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1EC9B8).withOpacity(.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Color(0xFF041818), size: 24),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legacy static request data (kept for reference)
// ---------------------------------------------------------------------------

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
    required this.name,
    required this.tripLabel,
    required this.dates,
    required this.timeAgo,
    required this.compatibility,
    required this.compatibilityHigh,
    required this.vibe,
    required this.budget,
    required this.verified,
    required this.avatarVariant,
  });
}
