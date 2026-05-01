// lib/features/trips/screens/create_trip_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/trips_provider.dart';
import '../../profile/providers/profile_provider.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────

class CreateTripSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.70),
      builder: (_) => const _CreateTripFlow(),
    );
  }
}

// ─── Colours ──────────────────────────────────────────────────────────────────

const _kBg      = Color(0xFF070E0F);
const _kSurface = Color(0xFF0D1819);
const _kTeal    = Color(0xFF1EC9B8);
const _kTeal2   = Color(0xFF58DAD0);
const _kGold    = Color(0xFFF7B84E);
const _kText    = Color(0xFFEDF7F4);
const _kMuted   = Color(0xFFA8C4BF);
const _kFaint   = Color(0xFF6A8882);

// ─── Destination data ─────────────────────────────────────────────────────────

class _Destination {
  final String name;
  final String emoji;
  final String region;
  const _Destination(this.name, this.emoji, this.region);
}

const _kDestinations = [
  // India – Mountains
  _Destination('Manali', '🏔', 'India · Mountains'),
  _Destination('Kasol', '🌿', 'India · Mountains'),
  _Destination('Spiti Valley', '🗻', 'India · Mountains'),
  _Destination('Leh Ladakh', '🏔', 'India · Mountains'),
  _Destination('Dharamshala', '🌄', 'India · Mountains'),
  _Destination('Rishikesh', '🌊', 'India · Mountains'),
  _Destination('Uttarkashi', '⛺', 'India · Mountains'),
  _Destination('Chopta', '🦌', 'India · Mountains'),
  _Destination('Auli', '⛷', 'India · Mountains'),
  _Destination('Munsiyari', '🌨', 'India · Mountains'),

  // India – Beaches
  _Destination('Goa', '🌊', 'India · Beaches'),
  _Destination('Varkala', '🏖', 'India · Beaches'),
  _Destination('Pondicherry', '🌺', 'India · Beaches'),
  _Destination('Gokarna', '🐚', 'India · Beaches'),
  _Destination('Andaman Islands', '🏝', 'India · Beaches'),
  _Destination('Lakshadweep', '🐠', 'India · Beaches'),
  _Destination('Alibaug', '⛵', 'India · Beaches'),
  _Destination('Tarkarli', '🤿', 'India · Beaches'),

  // India – South
  _Destination('Kerala', '🌴', 'India · South'),
  _Destination('Coorg', '☕', 'India · South'),
  _Destination('Ooty', '🚂', 'India · South'),
  _Destination('Munnar', '🍃', 'India · South'),
  _Destination('Hampi', '🏛', 'India · South'),
  _Destination('Mysore', '🎭', 'India · South'),
  _Destination('Wayanad', '🐘', 'India · South'),
  _Destination('Alleppey', '🛶', 'India · South'),

  // India – Rajasthan
  _Destination('Jaipur', '🏰', 'India · Rajasthan'),
  _Destination('Udaipur', '🏯', 'India · Rajasthan'),
  _Destination('Jodhpur', '💙', 'India · Rajasthan'),
  _Destination('Jaisalmer', '🏜', 'India · Rajasthan'),
  _Destination('Pushkar', '🐪', 'India · Rajasthan'),
  _Destination('Mount Abu', '🌅', 'India · Rajasthan'),
  _Destination('Bikaner', '🐫', 'India · Rajasthan'),

  // India – East & NE
  _Destination('Darjeeling', '🍵', 'India · East & NE'),
  _Destination('Sikkim', '🌸', 'India · East & NE'),
  _Destination('Meghalaya', '🌧', 'India · East & NE'),
  _Destination('Assam', '🦏', 'India · East & NE'),
  _Destination('Arunachal Pradesh', '🌄', 'India · East & NE'),
  _Destination('Ziro Valley', '🎋', 'India · East & NE'),
  _Destination('Kaziranga', '🦏', 'India · East & NE'),
  _Destination('Cherrapunji', '☔', 'India · East & NE'),

  // South-East Asia
  _Destination('Bali', '🌺', 'South-East Asia'),
  _Destination('Bangkok', '🛺', 'South-East Asia'),
  _Destination('Chiang Mai', '🐘', 'South-East Asia'),
  _Destination('Phuket', '🏝', 'South-East Asia'),
  _Destination('Krabi', '🌊', 'South-East Asia'),
  _Destination('Koh Samui', '🥥', 'South-East Asia'),
  _Destination('Vietnam', '🍜', 'South-East Asia'),
  _Destination('Hoi An', '🏮', 'South-East Asia'),
  _Destination('Ha Long Bay', '⛵', 'South-East Asia'),
  _Destination('Cambodia', '🏛', 'South-East Asia'),
  _Destination('Singapore', '🦁', 'South-East Asia'),
  _Destination('Bohol', '🌿', 'South-East Asia'),
  _Destination('Palawan', '🏝', 'South-East Asia'),

  // Central Asia & Nepal
  _Destination('Nepal', '🏔', 'Central Asia & Nepal'),
  _Destination('Kathmandu', '🙏', 'Central Asia & Nepal'),
  _Destination('Pokhara', '🚣', 'Central Asia & Nepal'),
  _Destination('Bhutan', '🐉', 'Central Asia & Nepal'),
  _Destination('Sri Lanka', '🌿', 'Central Asia & Nepal'),
  _Destination('Maldives', '🐬', 'Central Asia & Nepal'),

  // Europe
  _Destination('Paris', '🗼', 'Europe'),
  _Destination('Barcelona', '🏖', 'Europe'),
  _Destination('Amsterdam', '🌷', 'Europe'),
  _Destination('Rome', '🍕', 'Europe'),
  _Destination('Prague', '🍺', 'Europe'),
  _Destination('Santorini', '🌅', 'Europe'),
  _Destination('Amalfi Coast', '🍋', 'Europe'),
  _Destination('Dubrovnik', '🏰', 'Europe'),
  _Destination('Iceland', '🌋', 'Europe'),
  _Destination('Swiss Alps', '⛷', 'Europe'),

  // Americas & Others
  _Destination('New York', '🗽', 'Americas'),
  _Destination('Mexico City', '🌮', 'Americas'),
  _Destination('Rio de Janeiro', '🎭', 'Americas'),
  _Destination('Machu Picchu', '🏔', 'Americas'),
  _Destination('Tokyo', '⛩', 'East Asia'),
  _Destination('Kyoto', '🍁', 'East Asia'),
  _Destination('Osaka', '🦌', 'East Asia'),
  _Destination('Seoul', '🏙', 'East Asia'),
  _Destination('Dubai', '🏙', 'Middle East'),
  _Destination('Istanbul', '🕌', 'Middle East'),
  _Destination('Cairo', '🏺', 'Africa & Middle East'),
  _Destination('Marrakech', '🌿', 'Africa & Middle East'),
  _Destination('Zanzibar', '🏝', 'Africa & Middle East'),
  _Destination('Cape Town', '🦁', 'Africa & Middle East'),
];

// ─── Root flow widget ─────────────────────────────────────────────────────────

class _CreateTripFlow extends ConsumerStatefulWidget {
  const _CreateTripFlow();

  @override
  ConsumerState<_CreateTripFlow> createState() => _CreateTripFlowState();
}

class _CreateTripFlowState extends ConsumerState<_CreateTripFlow> {
  int _step = 0;

  String _destination = '';
  String _dates       = '';
  String _vibe        = '';
  String _budget      = '';
  String _intent      = '';

  int get _missing => [_vibe, _budget, _intent].where((v) => v.isEmpty).length;
  bool get _canPreview => _destination.isNotEmpty && _dates.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final bi = MediaQuery.of(context).padding.bottom;

    final profileAsync = ref.watch(myProfileProvider);
    final profile = profileAsync.value;
    final userName    = profile?.name ?? '';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    final userCity    = profile?.baseCity ?? '';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        height: sh * 0.96,
        color: _kBg,
        child: _step == 0
            ? _StepBuilder(
          destination: _destination,
          dates:       _dates,
          vibe:        _vibe,
          budget:      _budget,
          intent:      _intent,
          missing:     _missing,
          canPreview:  _canPreview,
          bottomInset: bi,
          userName:    userName,
          userInitial: userInitial,
          onClose: () => Navigator.of(context).pop(),
          onDestinationTap: () => _pickDestination(),
          onDatesTap: () => _pickField('Dates', ['May 10–14', 'May 12–15', 'May 18–22', 'May 20–25', 'Jun 1–7', 'Jun 14–20'], (v) => setState(() => _dates = v)),
          onVibeTap: () => _pickField('Vibe', ['🌊 Beach & Chill', '🏔 Adventure', '🎉 Party', '🏛 Culture', '🧘 Spiritual', '🌿 Nature'], (v) => setState(() => _vibe = v)),
          onBudgetTap: () => _pickField('Budget', ['₹ Budget', '₹₹ Mid-range', '₹₹₹ Comfortable', '💎 Luxury'], (v) => setState(() => _budget = v)),
          onIntentTap: () => _typeIntent(),
          onNext: () => setState(() => _step = 1),
        )
            : _StepPreview(
          destination: _destination,
          dates:       _dates,
          vibe:        _vibe,
          budget:      _budget,
          intent:      _intent,
          bottomInset: bi,
          userName:    userName,
          userInitial: userInitial,
          userCity:    userCity,
          onBack: () => setState(() => _step = 0),
          onBroadcast: () async {
            try {
              await ref.read(createTripProvider.notifier).create(
                destination: _destination,
                dates:       _dates,
                vibe:        _vibe.isNotEmpty ? _vibe : null,
                budget:      _budget.isNotEmpty ? _budget : null,
                intent:      _intent.isNotEmpty ? _intent : null,
              );
            } catch (_) {}
            if (mounted) {
              Navigator.of(context).pop();
              _showSuccessSnack(context);
            }
          },
        ),
      ),
    );
  }

  void _pickDestination() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DestinationPickerSheet(
        onPick: (v) => setState(() => _destination = v),
      ),
    );
  }

  void _pickField(String label, List<String> options, ValueChanged<String> onPick) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PickerSheet(label: label, options: options, onPick: onPick),
    );
  }

  void _typeIntent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IntentSheet(
        initial: _intent,
        onSave: (v) => setState(() => _intent = v),
      ),
    );
  }

  void _showSuccessSnack(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        backgroundColor: _kTeal.withOpacity(.15),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        duration: const Duration(seconds: 3),
        content: Row(
          children: const [
            Icon(Icons.sensors_rounded, color: _kTeal2, size: 20),
            SizedBox(width: 10),
            Text(
              'Live on radar — travelers notified!',
              style: TextStyle(color: _kText, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Destination Picker Sheet ─────────────────────────────────────────────────

class _DestinationPickerSheet extends StatefulWidget {
  final ValueChanged<String> onPick;
  const _DestinationPickerSheet({required this.onPick});

  @override
  State<_DestinationPickerSheet> createState() => _DestinationPickerSheetState();
}

class _DestinationPickerSheetState extends State<_DestinationPickerSheet>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _query = '';
  String? _selectedRegion;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  List<String> get _regions {
    final seen = <String>{};
    return _kDestinations.map((d) => d.region).where((r) => seen.add(r)).toList();
  }

  List<_Destination> get _filtered {
    var list = _kDestinations.toList();
    if (_selectedRegion != null) {
      list = list.where((d) => d.region == _selectedRegion).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((d) =>
          d.name.toLowerCase().contains(q) ||
          d.region.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Map<String, List<_Destination>> get _grouped {
    final map = <String, List<_Destination>>{};
    for (final d in _filtered) {
      map.putIfAbsent(d.region, () => []).add(d);
    }
    return map;
  }

  // Build flat list items for CustomScrollView sliver
  List<_ListItem> get _flatItems {
    final items = <_ListItem>[];
    for (final entry in _grouped.entries) {
      items.add(_ListItem.header(entry.key));
      for (final dest in entry.value) {
        items.add(_ListItem.dest(dest));
      }
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String v) {
    setState(() {
      _query = v.trim();
      _selectedRegion = null;
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _query = '');
  }

  void _selectRegion(String? region) {
    _searchCtrl.clear();
    setState(() {
      _selectedRegion = region;
      _query = '';
    });
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bi = mq.padding.bottom;
    final flatItems = _flatItems;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        // Use a DraggableScrollableSheet-style height that respects safe area
        height: mq.size.height * 0.90,
        decoration: const BoxDecoration(
          color: Color(0xFF0A1516),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // ── Handle ───────────────────────────────────────────────────────
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── Header ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Where to?',
                          style: TextStyle(
                            color: _kText, fontSize: 20, fontWeight: FontWeight.w800,
                          )),
                        SizedBox(height: 2),
                        Text('Search any city, region or country',
                          style: TextStyle(color: _kFaint, fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded, color: _kMuted, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _query.isNotEmpty
                        ? _kTeal.withOpacity(.45)
                        : _kTeal.withOpacity(.20),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _query.isNotEmpty
                          ? const Icon(Icons.search_rounded, color: _kTeal2, size: 20,
                              key: ValueKey('active'))
                          : Icon(Icons.search_rounded,
                              color: _kFaint, size: 20, key: const ValueKey('idle')),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: false,
                        style: const TextStyle(
                          color: _kText, fontSize: 15, fontWeight: FontWeight.w500),
                        onChanged: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Goa, Manali, Bali, Paris...',
                          hintStyle: const TextStyle(color: _kFaint, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: _clearSearch,
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(Icons.cancel_rounded,
                                        color: _kFaint, size: 18),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Region filter chips ───────────────────────────────────────────
            SizedBox(
              height: 34,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _RegionChip(
                    label: '✦ All',
                    selected: _selectedRegion == null && _query.isEmpty,
                    onTap: () => _selectRegion(null),
                  ),
                  const SizedBox(width: 8),
                  ..._regions.map((r) {
                    final short = r.split(' · ').last;
                    final regionEmoji = _regionEmoji(r);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _RegionChip(
                        label: '$regionEmoji $short',
                        selected: _selectedRegion == r,
                        onTap: () => _selectRegion(r),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Divider ───────────────────────────────────────────────────────
            Divider(height: 1, color: Colors.white.withOpacity(.07),
                indent: 16, endIndent: 16),

            // ── Result count strip ────────────────────────────────────────────
            if (_query.isNotEmpty || _selectedRegion != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Text(
                      '${_filtered.length} destination${_filtered.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: _kTeal2, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    if (_query.isNotEmpty) ...[
                      const Text('  for  ',
                          style: TextStyle(color: _kFaint, fontSize: 11)),
                      Text('"$_query"',
                          style: const TextStyle(
                              color: _kMuted, fontSize: 11, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),

            // ── List ──────────────────────────────────────────────────────────
            Expanded(
              child: flatItems.isEmpty
                  ? _EmptyState(query: _query)
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bi),
                      itemCount: flatItems.length,
                      itemBuilder: (ctx, i) {
                        final item = flatItems[i];
                        if (item.isHeader) {
                          return _RegionHeader(label: item.label!);
                        }
                        return _DestRow(
                          destination: item.dest!,
                          query: _query,
                          onTap: () {
                            widget.onPick(item.dest!.name);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _regionEmoji(String region) {
    if (region.contains('Mountains')) return '🏔';
    if (region.contains('Beaches')) return '🏖';
    if (region.contains('South')) return '🌴';
    if (region.contains('Rajasthan')) return '🏜';
    if (region.contains('East')) return '🌸';
    if (region.contains('South-East')) return '🌺';
    if (region.contains('Central') || region.contains('Nepal')) return '🐉';
    if (region.contains('Europe')) return '🗺';
    if (region.contains('Americas')) return '🗽';
    if (region.contains('East Asia')) return '⛩';
    if (region.contains('Middle')) return '🕌';
    if (region.contains('Africa')) return '🦁';
    return '📍';
  }
}

// ─── List item model ──────────────────────────────────────────────────────────

class _ListItem {
  final bool isHeader;
  final String? label;
  final _Destination? dest;
  const _ListItem._({required this.isHeader, this.label, this.dest});
  factory _ListItem.header(String label) =>
      _ListItem._(isHeader: true, label: label);
  factory _ListItem.dest(_Destination d) =>
      _ListItem._(isHeader: false, dest: d);
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✈️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 14),
          Text(
            query.isEmpty ? 'No destinations' : 'No results for "$query"',
            style: const TextStyle(color: _kMuted, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different name or browse all',
            style: TextStyle(color: _kFaint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Region chip ──────────────────────────────────────────────────────────────

class _RegionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RegionChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kTeal.withOpacity(.18) : Colors.white.withOpacity(.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _kTeal.withOpacity(.55) : Colors.white.withOpacity(.08),
            width: selected ? 1.2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _kTeal.withOpacity(.15), blurRadius: 8)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _kTeal2 : _kMuted,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Region header ────────────────────────────────────────────────────────────

class _RegionHeader extends StatelessWidget {
  final String label;
  const _RegionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
      child: Row(
        children: [
          Container(
            width: 3, height: 12,
            decoration: BoxDecoration(
              color: _kTeal2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: _kTeal2,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Destination row ──────────────────────────────────────────────────────────

class _DestRow extends StatelessWidget {
  final _Destination destination;
  final VoidCallback onTap;
  final String query;
  const _DestRow({required this.destination, required this.onTap, this.query = ''});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(.08),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _kTeal.withOpacity(.15)),
              ),
              child: Center(
                child: Text(destination.emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightText(
                    text: destination.name,
                    query: query,
                    baseStyle: const TextStyle(
                      color: _kText, fontSize: 15, fontWeight: FontWeight.w700),
                    highlightStyle: const TextStyle(
                      color: _kTeal2, fontSize: 15, fontWeight: FontWeight.w700,
                      backgroundColor: Color(0x221EC9B8)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    destination.region,
                    style: const TextStyle(color: _kFaint, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: _kFaint, size: 13),
          ],
        ),
      ),
    );
  }
}

// ─── Highlight text (bold-matches search query) ────────────────────────────────

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;
  const _HighlightText({
    required this.text, required this.query,
    required this.baseStyle, required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final start = lower.indexOf(q);
    if (start < 0) return Text(text, style: baseStyle);
    final end = start + q.length;
    return RichText(
      text: TextSpan(children: [
        if (start > 0) TextSpan(text: text.substring(0, start), style: baseStyle),
        TextSpan(text: text.substring(start, end), style: highlightStyle),
        if (end < text.length) TextSpan(text: text.substring(end), style: baseStyle),
      ]),
    );
  }
}

// ─── Step 1: Builder ──────────────────────────────────────────────────────────

class _StepBuilder extends StatelessWidget {
  final String destination, dates, vibe, budget, intent;
  final int missing;
  final bool canPreview;
  final double bottomInset;
  final String userName, userInitial;
  final VoidCallback onClose, onDestinationTap, onDatesTap, onVibeTap,
      onBudgetTap, onIntentTap, onNext;

  const _StepBuilder({
    required this.destination, required this.dates,
    required this.vibe, required this.budget, required this.intent,
    required this.missing, required this.canPreview,
    required this.bottomInset,
    required this.userName, required this.userInitial,
    required this.onClose, required this.onDestinationTap,
    required this.onDatesTap, required this.onVibeTap,
    required this.onBudgetTap, required this.onIntentTap, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60, left: 0, right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.0,
                colors: [_kTeal.withOpacity(.12), Colors.transparent],
              ),
            ),
          ),
        ),

        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close_rounded, color: _kText, size: 18),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Design your Trip', style: TextStyle(
                        color: _kText, fontSize: 16, fontWeight: FontWeight.w700,
                      )),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  height: 4,
                  color: Colors.white.withOpacity(.10),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.5,
                    child: Container(color: _kTeal2),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 120 + bottomInset),
                child: _TripWidgetCard(
                  destination: destination, dates: dates,
                  vibe: vibe, budget: budget, intent: intent,
                  userName: userName, userInitial: userInitial,
                  onDestinationTap: onDestinationTap,
                  onDatesTap: onDatesTap,
                  onVibeTap: onVibeTap,
                  onBudgetTap: onBudgetTap,
                  onIntentTap: onIntentTap,
                ),
              ),
            ),
          ],
        ),

        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, _kBg],
                stops: const [0.0, 0.25],
              ),
              color: _kBg,
            ),
            child: GestureDetector(
              onTap: canPreview ? onNext : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 56,
                decoration: BoxDecoration(
                  color: canPreview
                      ? Colors.white.withOpacity(.08)
                      : Colors.white.withOpacity(.04),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: canPreview
                        ? Colors.white.withOpacity(.14)
                        : Colors.white.withOpacity(.07),
                  ),
                ),
                child: Center(
                  child: Text(
                    missing == 0
                        ? 'Preview my Trip →'
                        : '$missing item${missing == 1 ? '' : 's'} missing',
                    style: TextStyle(
                      color: canPreview ? _kText : _kFaint,
                      fontSize: 15, fontWeight: FontWeight.w800,
                    ),
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

// ─── Trip widget card ─────────────────────────────────────────────────────────

class _TripWidgetCard extends StatelessWidget {
  final String destination, dates, vibe, budget, intent;
  final String userName, userInitial;
  final VoidCallback onDestinationTap, onDatesTap, onVibeTap,
      onBudgetTap, onIntentTap;

  const _TripWidgetCard({
    required this.destination, required this.dates,
    required this.vibe, required this.budget, required this.intent,
    required this.userName, required this.userInitial,
    required this.onDestinationTap, required this.onDatesTap,
    required this.onVibeTap, required this.onBudgetTap, required this.onIntentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(.04),
            Colors.white.withOpacity(.01),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.4),
            blurRadius: 50, offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                gradient: RadialGradient(
                  center: Alignment.topCenter, radius: 1.0,
                  colors: [_kTeal.withOpacity(.15), Colors.transparent],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [_kTeal2, _kTeal, _kGold],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(userInitial, style: const TextStyle(
                          color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800,
                        )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'You',
                          style: const TextStyle(
                            color: _kText, fontSize: 16, fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('Building your broadcast...', style: TextStyle(
                          color: _kFaint, fontSize: 12,
                        )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _Slot(
                        label: 'Destination',
                        value: destination.isNotEmpty ? '📍 $destination' : null,
                        placeholder: '+ Set Destination',
                        filled: destination.isNotEmpty,
                        onTap: onDestinationTap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Slot(
                        label: 'Dates',
                        value: dates.isNotEmpty ? '📅 $dates' : null,
                        placeholder: '+ Add Dates',
                        filled: dates.isNotEmpty,
                        onTap: onDatesTap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _Slot(
                        label: 'Energy / Vibe',
                        value: vibe.isNotEmpty ? vibe : null,
                        placeholder: '+ Set Vibe',
                        filled: false,
                        onTap: onVibeTap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Slot(
                        label: 'Budget',
                        value: budget.isNotEmpty ? budget : null,
                        placeholder: '+ Add Budget',
                        filled: false,
                        onTap: onBudgetTap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _IntentSlot(value: intent, onTap: onIntentTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slot ─────────────────────────────────────────────────────────────────────

class _Slot extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final bool filled;
  final VoidCallback onTap;

  const _Slot({
    required this.label, required this.value, required this.placeholder,
    required this.filled, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == null || value!.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isEmpty
              ? _kTeal.withOpacity(.05)
              : Colors.black.withOpacity(.30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEmpty
                ? _kTeal.withOpacity(.40)
                : Colors.white.withOpacity(.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(
              color: _kFaint, fontSize: 10, fontWeight: FontWeight.w800,
              letterSpacing: .05,
            )),
            const SizedBox(height: 6),
            Text(
              value ?? placeholder,
              style: TextStyle(
                color: isEmpty ? _kTeal2 : _kText,
                fontSize: isEmpty ? 13 : 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Intent slot ──────────────────────────────────────────────────────────────

class _IntentSlot extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _IntentSlot({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: isEmpty
            ? const EdgeInsets.symmetric(vertical: 24, horizontal: 16)
            : const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEmpty ? _kTeal.withOpacity(.05) : Colors.black.withOpacity(.30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEmpty ? _kTeal.withOpacity(.40) : Colors.white.withOpacity(.06),
          ),
        ),
        child: isEmpty
            ? Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: _kTeal2, size: 20,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Tap to add intent', style: TextStyle(
              color: _kTeal2, fontSize: 14, fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 4),
            const Text('Tell them why you\'re going', style: TextStyle(
              color: _kMuted, fontSize: 11,
            )),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('INTENT', style: TextStyle(
              color: _kFaint, fontSize: 10, fontWeight: FontWeight.w800,
              letterSpacing: .05,
            )),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(
              color: _kText, fontSize: 13, height: 1.5,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Step 2: Preview + Radar ──────────────────────────────────────────────────

class _StepPreview extends StatefulWidget {
  final String destination, dates, vibe, budget, intent;
  final double bottomInset;
  final String userName, userInitial, userCity;
  final VoidCallback onBack, onBroadcast;

  const _StepPreview({
    required this.destination, required this.dates,
    required this.vibe, required this.budget, required this.intent,
    required this.bottomInset,
    required this.userName, required this.userInitial, required this.userCity,
    required this.onBack, required this.onBroadcast,
  });

  @override
  State<_StepPreview> createState() => _StepPreviewState();
}

class _StepPreviewState extends State<_StepPreview> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: _kText, size: 16),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('FINAL STEP', style: TextStyle(
                        color: _kGold, fontSize: 14, fontWeight: FontWeight.w800,
                        letterSpacing: .06,
                      )),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  height: 4, color: Colors.white.withOpacity(.10),
                  child: const FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: _kGold),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 140 + widget.bottomInset),
                child: Column(
                  children: [
                    const Text('Ready to broadcast 📡', style: TextStyle(
                      color: _kText, fontSize: 26, fontWeight: FontWeight.w800,
                      letterSpacing: -.4,
                    )),
                    const SizedBox(height: 8),
                    Text(
                      'Here is exactly what other travelers heading to ${widget.destination} will see.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _kMuted, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    _PreviewCard(
                      destination: widget.destination,
                      dates: widget.dates,
                      vibe: widget.vibe,
                      budget: widget.budget,
                      intent: widget.intent,
                      userName: widget.userName,
                      userInitial: widget.userInitial,
                      userCity: widget.userCity,
                    ),

                    const SizedBox(height: 36),

                    _RadarWidget(destination: widget.destination),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),

        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 16 + widget.bottomInset),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, _kBg],
                stops: const [0.0, 0.22],
              ),
              color: _kBg,
            ),
            child: GestureDetector(
              onTap: widget.onBroadcast,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFFF7B84E), Color(0xFFE09620)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(.30),
                      blurRadius: 40, offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.sensors_rounded, color: Color(0xFF041818), size: 22),
                    SizedBox(width: 10),
                    Text('Publish to Live Radar', style: TextStyle(
                      color: Color(0xFF041818),
                      fontSize: 16, fontWeight: FontWeight.w800,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Preview card ─────────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final String destination, dates, vibe, budget, intent;
  final String userName, userInitial, userCity;

  const _PreviewCard({
    required this.destination, required this.dates,
    required this.vibe, required this.budget, required this.intent,
    required this.userName, required this.userInitial, required this.userCity,
  });

  @override
  Widget build(BuildContext context) {
    final hasIntent = intent.isNotEmpty;
    final hasVibe   = vibe.isNotEmpty;
    final hasBudget = budget.isNotEmpty;

    return FractionallySizedBox(
      widthFactor: 0.92,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [
              _kTeal.withOpacity(.08),
              Colors.white.withOpacity(.02),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kTeal.withOpacity(.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.30),
              blurRadius: 30, offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kTeal2, _kTeal, _kGold],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(userInitial, style: const TextStyle(
                          color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800,
                        )),
                      ),
                    ),
                    Positioned(
                      bottom: -6, left: 0, right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(.10)),
                          ),
                          child: const Text('YOU', style: TextStyle(
                            color: _kText, fontSize: 9, fontWeight: FontWeight.w800,
                            letterSpacing: .05,
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userName.isNotEmpty ? userName : 'You',
                            style: const TextStyle(
                              color: _kText, fontSize: 16, fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, color: _kTeal2, size: 12),
                        ],
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          children: [
                            TextSpan(
                              text: userCity.isNotEmpty ? '$userCity ' : '',
                              style: const TextStyle(color: _kTeal2),
                            ),
                            if (userCity.isNotEmpty)
                              const TextSpan(text: '→ ', style: TextStyle(color: _kText)),
                            TextSpan(text: destination, style: const TextStyle(color: _kTeal2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(dates, style: const TextStyle(
                      color: _kText, fontSize: 12, fontWeight: FontWeight.w800,
                    )),
                    const SizedBox(height: 2),
                    const Text('4 Days', style: TextStyle(
                      color: _kFaint, fontSize: 10,
                    )),
                  ],
                ),
              ],
            ),

            if (hasIntent || hasVibe || hasBudget) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.50),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasIntent) ...[
                      Text('"$intent"', style: const TextStyle(
                        color: _kText, fontSize: 13, height: 1.5,
                      )),
                      const SizedBox(height: 12),
                    ],
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: [
                        if (hasVibe)   _Tag(label: vibe,   type: 'teal'),
                        if (hasBudget) _Tag(label: budget, type: 'gray'),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.remove_red_eye_outlined, color: _kTeal2, size: 13),
                SizedBox(width: 5),
                Text('Preview Mode', style: TextStyle(
                  color: _kTeal2, fontSize: 11, fontWeight: FontWeight.w700,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tag chip ─────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final String type;
  const _Tag({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg, fg, border;
    switch (type) {
      case 'teal':
        bg = _kTeal.withOpacity(.15); fg = _kTeal2; border = _kTeal.withOpacity(.20);
        break;
      case 'gold':
        bg = _kGold.withOpacity(.15); fg = _kGold; border = _kGold.withOpacity(.20);
        break;
      default:
        bg = Colors.white.withOpacity(.08); fg = _kMuted; border = Colors.white.withOpacity(.10);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border),
      ),
      child: Text(label, style: TextStyle(
        color: fg, fontSize: 10, fontWeight: FontWeight.w700,
      )),
    );
  }
}

// ─── Generic Picker sheet (Dates, Vibe, Budget) ───────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onPick;

  const _PickerSheet({
    required this.label,
    required this.options,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final bi = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1819),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bi),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(label, style: const TextStyle(
            color: _kText, fontSize: 16, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 16),
          ...options.map((opt) => GestureDetector(
            onTap: () {
              onPick(opt);
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(.07)),
              ),
              child: Text(opt, style: const TextStyle(
                color: _kText, fontSize: 14, fontWeight: FontWeight.w600,
              )),
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Intent sheet ─────────────────────────────────────────────────────────────

class _IntentSheet extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onSave;

  const _IntentSheet({required this.initial, required this.onSave});

  @override
  State<_IntentSheet> createState() => _IntentSheetState();
}

class _IntentSheetState extends State<_IntentSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bi = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1819),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bi),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Your Intent', style: TextStyle(
            color: _kText, fontSize: 16, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 6),
          const Text('Tell potential companions why you\'re going', style: TextStyle(
            color: _kMuted, fontSize: 12,
          )),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kTeal.withOpacity(.25)),
            ),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 4,
              maxLength: 200,
              style: const TextStyle(color: _kText, fontSize: 14, height: 1.5),
              decoration: InputDecoration(
                hintText: 'e.g. Looking for a chill travel buddy to explore beaches and try local food...',
                hintStyle: TextStyle(color: _kFaint, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                counterStyle: TextStyle(color: _kFaint, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              widget.onSave(_ctrl.text.trim());
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kTeal.withOpacity(.30)),
              ),
              child: const Center(
                child: Text('Save Intent', style: TextStyle(
                  color: _kTeal2, fontSize: 15, fontWeight: FontWeight.w800,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Radar widget ─────────────────────────────────────────────────────────────

class _RadarWidget extends StatefulWidget {
  final String destination;
  const _RadarWidget({required this.destination});

  @override
  State<_RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<_RadarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200, height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kTeal.withOpacity(.04),
            border: Border.all(color: _kTeal.withOpacity(.12)),
          ),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              return CustomPaint(
                painter: _RadarPainter(_ctrl.value),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Scanning for travelers near ${widget.destination}...',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _kMuted, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 6, height: 6,
              decoration: const BoxDecoration(color: _kTeal2, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('Live', style: TextStyle(
              color: _kTeal2, fontSize: 11, fontWeight: FontWeight.w700,
            )),
          ],
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  _RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..color = _kTeal.withOpacity(.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, ringPaint);
    }

    final sweepAngle = progress * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - 1.2,
        endAngle: sweepAngle,
        colors: [Colors.transparent, _kTeal.withOpacity(.40)],
        tileMode: TileMode.clamp,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, sweepPaint);

    final linePaint = Paint()
      ..color = _kTeal2.withOpacity(.8)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * math.cos(sweepAngle),
        center.dy + radius * math.sin(sweepAngle),
      ),
      linePaint,
    );

    final blipPaint = Paint()..color = _kTeal2;
    final blips = [
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.3),
      Offset(center.dx - radius * 0.55, center.dy + radius * 0.2),
      Offset(center.dx + radius * 0.2, center.dy + radius * 0.55),
    ];
    for (final b in blips) {
      canvas.drawCircle(b, 3, blipPaint);
    }

    canvas.drawCircle(center, 4, Paint()..color = _kTeal2);
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.progress != progress;
}
