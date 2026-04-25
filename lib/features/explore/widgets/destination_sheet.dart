// lib/features/explore/widgets/destination_sheet.dart

import 'package:flutter/material.dart';
import '../../profile/widgets/user_profile_sheet.dart';
import '../data/explore_data.dart';

const _kBg      = Color(0xFF0B1516);
const _kSurface = Color(0xFF0D1819);
const _kTeal    = Color(0xFF1EC9B8);
const _kTeal2   = Color(0xFF58DAD0);
const _kGold    = Color(0xFFF7B84E);
const _kText    = Color(0xFFEDF7F4);
const _kMuted   = Color(0xFFA8C4BF);
const _kFaint   = Color(0xFF6A8882);

class DestinationSheet extends StatelessWidget {
  final ExploreDestination destination;

  const DestinationSheet({super.key, required this.destination});

  static void show(BuildContext context, ExploreDestination dest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.60),
      builder: (_) => DestinationSheet(destination: dest),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final bi = MediaQuery.of(context).padding.bottom;
    final d  = destination;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        height: sh * 0.72,
        color: _kBg,
        child: Column(
          children: [
            // ── Hero photo ────────────────────────────────────────────────
            SizedBox(
              height: 180,
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
                            colors: [d.nodeColor.withOpacity(.4), _kBg],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(color: _kSurface),

                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(.20),
                            Colors.transparent,
                            _kBg,
                          ],
                          stops: const [0.0, 0.50, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Drag handle
                  Positioned(
                    top: 10, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.30),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),

                  // Live badge
                  Positioned(
                    top: 28, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.55),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(.10)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              color: _kTeal, shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${d.travelerCount} going',
                            style: const TextStyle(
                              color: _kTeal2, fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bi),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + region
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.name, style: const TextStyle(
                                color: _kText, fontSize: 24,
                                fontWeight: FontWeight.w800, letterSpacing: -.3,
                              )),
                              const SizedBox(height: 2),
                              Text(d.region, style: const TextStyle(
                                color: _kFaint, fontSize: 13,
                              )),
                            ],
                          ),
                        ),
                        // Vibe pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _kTeal.withOpacity(.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _kTeal.withOpacity(.20)),
                          ),
                          child: Text(d.topVibe, style: const TextStyle(
                            color: _kTeal2, fontSize: 12,
                            fontWeight: FontWeight.w700,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stats row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(.06)),
                      ),
                      child: Row(
                        children: [
                          _StatCell(value: '${d.travelerCount}', label: 'TRAVELERS'),
                          Container(width: 1, height: 32,
                              color: Colors.white.withOpacity(.06)),
                          _StatCell(value: d.dateRange.isNotEmpty
                              ? d.dateRange.split('–').first.trim()
                              : '—', label: 'FROM'),
                          Container(width: 1, height: 32,
                              color: Colors.white.withOpacity(.06)),
                          _StatCell(
                            value: '${d.topTravelers.isNotEmpty
                                ? d.topTravelers.first.matchPct
                                : 0}%',
                            label: 'TOP MATCH',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Travelers going here
                    const Text('Going here', style: TextStyle(
                      color: _kText, fontSize: 15, fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 12),

                    ...d.topTravelers.map((t) => _TravelerRow(
                      profile: t,
                      destination: d.name,
                      onTap: () {
                        Navigator.of(context).pop();
                        UserProfileSheet.show(context, name: t.name.split(' ').first);
                      },
                    )),

                    const SizedBox(height: 20),

                    // CTA
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: double.infinity, height: 54,
                        decoration: BoxDecoration(
                          color: _kText,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(.08),
                              blurRadius: 20, offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Find my match in ${d.name}',
                            style: const TextStyle(
                              color: Colors.black, fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat cell ────────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String value, label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(
            color: _kText, fontSize: 18, fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(
            color: _kFaint, fontSize: 10, fontWeight: FontWeight.w800,
            letterSpacing: .05,
          )),
        ],
      ),
    );
  }
}

// ─── Traveler row ─────────────────────────────────────────────────────────────

class _TravelerRow extends StatelessWidget {
  final ExploreProfile profile;
  final String destination;
  final VoidCallback onTap;

  const _TravelerRow({
    required this.profile,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = profile.color;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(profile.initial, style: TextStyle(
                  color: c, fontSize: 16, fontWeight: FontWeight.w800,
                )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: const TextStyle(
                    color: _kText, fontSize: 14, fontWeight: FontWeight.w700,
                  )),
                  Text(
                    '${profile.from} → $destination · ${profile.dates}',
                    style: const TextStyle(color: _kFaint, fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              '${profile.matchPct}%',
              style: TextStyle(
                color: c, fontSize: 13, fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: _kFaint, size: 16),
          ],
        ),
      ),
    );
  }
}