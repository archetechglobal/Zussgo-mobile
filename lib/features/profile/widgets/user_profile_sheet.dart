// lib/features/profile/widgets/user_profile_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/profile_model.dart';

// ─── Live trip provider for a user id ───────────────────────────────────────────────
final _userActiveTripProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) async {
  final rows = await supabase
      .from('trips')
      .select('id, destination, dates, vibe, spots_left')
      .eq('creator_id', uid)
      .eq('status', 'active')
      .order('created_at', ascending: false)
      .limit(1);
  if ((rows as List).isEmpty) return null;
  return rows.first as Map<String, dynamic>;
});

// ─── Reviews provider for a user id ─────────────────────────────────────────────────
final _userReviewsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, uid) async {
  final rows = await supabase
      .from('reviews')
      .select('reviewer_name, reviewer_initial, trip_label, text, stars')
      .eq('reviewee_id', uid)
      .order('created_at', ascending: false)
      .limit(5);
  return List<Map<String, dynamic>>.from(rows as List);
});

// ─── Colours ─────────────────────────────────────────────────────────────────────
const _kBg      = Color(0xFF0B1516);
const _kSurface = Color(0xFF0D1819);
const _kTeal    = Color(0xFF1EC9B8);
const _kTeal2   = Color(0xFF58DAD0);
const _kGold    = Color(0xFFF7B84E);
const _kText    = Color(0xFFEDF7F4);
const _kMuted   = Color(0xFFA8C4BF);
const _kFaint   = Color(0xFF6A8882);

// ─── Entry point ─────────────────────────────────────────────────────────────────────

class UserProfileSheet extends StatelessWidget {
  final ProfileModel profile;
  const UserProfileSheet({super.key, required this.profile});

  /// Pass the real [ProfileModel] — no name lookup, no mock data.
  static void show(BuildContext context, {ProfileModel? profile, String? name}) {
    assert(profile != null || name != null,
        'Either profile or name must be provided');

    if (profile != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(.65),
        builder: (_) => UserProfileSheet(profile: profile),
      );
    } else {
      // Legacy name-only call: fetch from Supabase then show.
      // This path exists only for backward compatibility.
      supabase
          .from('profiles')
          .select(
              'id, name, age, avatar_url, vibes, rating, trip_count, buddy_count, base_city, bio')
          .ilike('name', '%${name!.trim()}%')
          .limit(1)
          .maybeSingle()
          .then((row) {
        if (row == null) return;
        final p = ProfileModel.fromMap(row as Map<String, dynamic>);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(.65),
          builder: (_) => UserProfileSheet(profile: p),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: _UserProfileSheetBody(profile: profile),
    );
  }
}

// ─── Sheet body (consumer for live data) ──────────────────────────────────────────

class _UserProfileSheetBody extends ConsumerStatefulWidget {
  final ProfileModel profile;
  const _UserProfileSheetBody({required this.profile});

  @override
  ConsumerState<_UserProfileSheetBody> createState() =>
      _UserProfileSheetBodyState();
}

class _UserProfileSheetBodyState
    extends ConsumerState<_UserProfileSheetBody> {
  bool _showRequestForm = false;
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p          = widget.profile;
    final sh         = MediaQuery.of(context).size.height;
    final bi         = MediaQuery.of(context).padding.bottom;
    final tripAsync  = ref.watch(_userActiveTripProvider(p.id));
    final reviewsAsync = ref.watch(_userReviewsProvider(p.id));

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        height: sh * 0.94,
        color: _kBg,
        child: Stack(
          children: [
            // ── Scrollable body ───────────────────────────────────────────────────
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 140 + bi),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero photo
                  _ProfileHero(
                    profile: p,
                    onClose: () => Navigator.of(context).pop(),
                  ),

                  // 2. Name + location overlapping hero bottom
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${p.name ?? 'Traveler'}${p.age != null ? ', ${p.age}' : ''}',
                                    style: const TextStyle(
                                      color: _kText, fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _VerifiedBadge(),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (p.baseCity != null)
                                Text(
                                  '\uD83D\uDCCD Based in ${p.baseCity}',
                                  style: const TextStyle(
                                      color: _kMuted, fontSize: 14),
                                ),
                              const SizedBox(height: 20),
                              _StatsRow(
                                trips:   p.tripCount,
                                rating:  p.rating,
                                buddies: p.buddyCount,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 3. About Me
                        if (p.bio != null && p.bio!.isNotEmpty) ...[
                          _SectionTitle(title: 'About Me'),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              p.bio!,
                              style: const TextStyle(
                                  color: _kMuted, fontSize: 14, height: 1.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 4. Vibes
                        if (p.vibes.isNotEmpty) ...[
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              spacing: 8, runSpacing: 8,
                              children: p.vibes
                                  .map((v) => _VibeChip(label: v))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // 5. Active Trip (live)
                        tripAsync.when(
                          loading: () => const SizedBox(
                              height: 80,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: _kTeal, strokeWidth: 2))),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (trip) => trip != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, bottom: 32),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _SectionTitle(title: 'Active Trip'),
                                      _ActiveTripCard(
                                        destination: trip['destination']
                                                as String? ??
                                            'Trip',
                                        dates: trip['dates'] as String? ?? '',
                                        spotsLeft:
                                            trip['spots_left'] as int? ?? 0,
                                        vibe: trip['vibe'] as String?,
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 0, 20, 32),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.03),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(.06)),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'No active trip right now',
                                        style: TextStyle(
                                            color: _kFaint, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                        ),

                        // 6. Reviews (live)
                        reviewsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (reviews) => reviews.isEmpty
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _SectionTitle(
                                        title: 'Reviews',
                                        trailing: Text(
                                          'View ${reviews.length}',
                                          style: const TextStyle(
                                            color: _kTeal2,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      ...reviews.map((r) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: _ReviewCard(
                                              initial: (r['reviewer_initial']
                                                          as String?) ??
                                                      '?',
                                              name: (r['reviewer_name']
                                                          as String?) ??
                                                      'Anonymous',
                                              tripLabel:
                                                  (r['trip_label'] as String?) ??
                                                      '',
                                              text:
                                                  (r['text'] as String?) ?? '',
                                              stars: (r['stars'] as num?)
                                                      ?.toDouble() ??
                                                  5.0,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Fixed bottom CTA ───────────────────────────────────────────────────
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: _BottomCta(
                profile: p,
                activeTrip: tripAsync.asData?.value,
                showForm: _showRequestForm,
                msgCtrl: _msgCtrl,
                onAskToJoin: () =>
                    setState(() => _showRequestForm = true),
                onSend: () => Navigator.of(context).pop(),
                onDismiss: () =>
                    setState(() => _showRequestForm = false),
                bottomInset: bi,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onClose;
  const _ProfileHero({required this.profile, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Avatar photo or initial fallback
          profile.avatarUrl != null
              ? Image.network(
                  profile.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _AvatarFallback(profile: profile),
                )
              : _AvatarFallback(profile: profile),

          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.30),
                    Colors.transparent,
                    _kBg,
                  ],
                  stops: const [0.0, 0.40, 1.0],
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

          // Back button
          Positioned(
            top: 36, left: 20,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(.10)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded, color: _kText, size: 16),
              ),
            ),
          ),

          // Rating badge
          Positioned(
            bottom: 24, right: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.60),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(.10)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: _kGold, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    profile.rating.toStringAsFixed(1),
                    style: const TextStyle(
                        color: _kText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final ProfileModel profile;
  const _AvatarFallback({required this.profile});

  @override
  Widget build(BuildContext context) {
    final initial =
        (profile.name?.isNotEmpty == true) ? profile.name![0].toUpperCase() : '?';
    return Container(
      color: _kSurface,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
              color: _kTeal2, fontSize: 72, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Verified badge ───────────────────────────────────────────────────────────────────
class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration:
          const BoxDecoration(color: _kTeal2, shape: BoxShape.circle),
      child: const Center(
        child: Text('\u2713',
            style: TextStyle(
                color: Color(0xFF041818),
                fontSize: 10,
                fontWeight: FontWeight.w900)),
      ),
    );
  }
}

// ─── Stats row ──────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int trips;
  final double rating;
  final int buddies;
  const _StatsRow(
      {required this.trips, required this.rating, required this.buddies});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _StatCell(value: '$trips', label: 'TRIPS'),
          Container(
              width: 1,
              height: 36,
              color: Colors.white.withOpacity(.06)),
          _StatCell(value: rating.toStringAsFixed(1), label: 'RATING'),
          Container(
              width: 1,
              height: 36,
              color: Colors.white.withOpacity(.06)),
          _StatCell(value: '$buddies', label: 'BUDDIES'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: _kText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: _kFaint,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .05)),
        ],
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: _kText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Vibe chip ─────────────────────────────────────────────────────────────────────────
class _VibeChip extends StatelessWidget {
  final String label;
  const _VibeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _kTeal.withOpacity(.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kTeal.withOpacity(.20)),
      ),
      child: Text(label,
          style: const TextStyle(
              color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Active trip card ──────────────────────────────────────────────────────────────────
class _ActiveTripCard extends StatelessWidget {
  final String destination;
  final String dates;
  final int spotsLeft;
  final String? vibe;
  const _ActiveTripCard({
    required this.destination,
    required this.dates,
    required this.spotsLeft,
    this.vibe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_kTeal.withOpacity(.08), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kTeal.withOpacity(.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon placeholder
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _kTeal.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flight_takeoff_rounded,
                color: _kTeal2, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BROADCASTING',
                  style: TextStyle(
                      color: _kTeal2,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .05),
                ),
                const SizedBox(height: 4),
                Text(destination,
                    style: const TextStyle(
                        color: _kText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  [
                    if (dates.isNotEmpty) dates,
                    if (spotsLeft > 0) 'Looking for $spotsLeft',
                    if (vibe != null) vibe!,
                  ].join(' · '),
                  style: const TextStyle(color: _kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Review card ───────────────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final String initial;
  final String name;
  final String tripLabel;
  final String text;
  final double stars;
  const _ReviewCard({
    required this.initial,
    required this.name,
    required this.tripLabel,
    required this.text,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _kTeal.withOpacity(.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Text(initial,
                            style: const TextStyle(
                                color: _kTeal2,
                                fontSize: 14,
                                fontWeight: FontWeight.w700))),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              color: _kText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text(tripLabel,
                          style: const TextStyle(
                              color: _kMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(
                  stars.round(),
                  (_) => const Icon(Icons.star_rounded,
                      color: _kGold, size: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(text,
              style:
                  const TextStyle(color: _kText, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── Bottom CTA ───────────────────────────────────────────────────────────────────────
class _BottomCta extends StatelessWidget {
  final ProfileModel profile;
  final Map<String, dynamic>? activeTrip;
  final bool showForm;
  final TextEditingController msgCtrl;
  final VoidCallback onAskToJoin;
  final VoidCallback onSend;
  final VoidCallback onDismiss;
  final double bottomInset;

  const _BottomCta({
    required this.profile,
    required this.activeTrip,
    required this.showForm,
    required this.msgCtrl,
    required this.onAskToJoin,
    required this.onSend,
    required this.onDismiss,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      decoration: BoxDecoration(
        color: _kBg,
        border:
            Border(top: BorderSide(color: Colors.white.withOpacity(.06))),
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, _kBg],
          stops: const [0.0, 0.2],
        ),
      ),
      child: showForm
          ? _RequestForm(
              profileName: profile.name ?? 'Traveler',
              tripName: activeTrip?['destination'] as String? ?? 'their trip',
              msgCtrl: msgCtrl,
              onSend: onSend,
              onDismiss: onDismiss,
            )
          : _JoinCta(
              profileName: profile.name ?? 'Traveler',
              hasActiveTrip: activeTrip != null,
              onAskToJoin: onAskToJoin,
            ),
    );
  }
}

class _JoinCta extends StatelessWidget {
  final String profileName;
  final bool hasActiveTrip;
  final VoidCallback onAskToJoin;
  const _JoinCta({
    required this.profileName,
    required this.hasActiveTrip,
    required this.onAskToJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: hasActiveTrip ? onAskToJoin : null,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: hasActiveTrip ? _kText : _kText.withOpacity(.3),
              borderRadius: BorderRadius.circular(16),
              boxShadow: hasActiveTrip
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                hasActiveTrip ? 'Ask to Join Trip' : 'No active trip',
                style: TextStyle(
                  color: hasActiveTrip ? Colors.black : _kFaint,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        if (hasActiveTrip) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded,
                  color: _kFaint, size: 12),
              const SizedBox(width: 4),
              Text(
                'Messaging unlocks if $profileName accepts',
                style: const TextStyle(
                    color: _kFaint,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RequestForm extends StatelessWidget {
  final String profileName;
  final String tripName;
  final TextEditingController msgCtrl;
  final VoidCallback onSend;
  final VoidCallback onDismiss;
  const _RequestForm({
    required this.profileName,
    required this.tripName,
    required this.msgCtrl,
    required this.onSend,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.20),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const Center(
          child: Text('Request to Join',
              style: TextStyle(
                  color: _kText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 8),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                  color: _kMuted, fontSize: 13, height: 1.4),
              children: [
                const TextSpan(text: 'You are asking to join '),
                TextSpan(
                    text: tripName,
                    style: const TextStyle(
                        color: _kText, fontWeight: FontWeight.w600)),
                TextSpan(
                    text: '. Introduce yourself to $profileName!'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('YOUR MESSAGE',
                  style: TextStyle(
                      color: _kFaint,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .05)),
              const SizedBox(height: 12),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                style: const TextStyle(
                    color: _kText, fontSize: 14, height: 1.5),
                decoration: InputDecoration(
                  hintText:
                      'Hey $profileName! Your trip sounds exactly like what I\'m looking for...',
                  hintStyle:
                      const TextStyle(color: _kFaint, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onSend,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: _kTeal,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: _kTeal.withOpacity(.20),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
              ],
            ),
            child: const Center(
              child: Text('Send Request',
                  style: TextStyle(
                      color: Color(0xFF041818),
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ],
    );
  }
}
