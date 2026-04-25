// lib/features/profile/screens/companion_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/user_profile_sheet.dart';

class CompanionProfileScreen extends StatefulWidget {
  final UserProfileData profile;

  const CompanionProfileScreen({
    super.key,
    required this.profile,
  });

  static Route route(UserProfileData profile) {
    return PageRouteBuilder(
      opaque: true,
      fullscreenDialog: false,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => CompanionProfileScreen(profile: profile),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CompanionProfileScreen> createState() => _CompanionProfileScreenState();
}

class _CompanionProfileScreenState extends State<CompanionProfileScreen> {
  bool _showRequestForm = false;
  final _msgCtrl = TextEditingController();

  static const bg      = Color(0xFF070E0F);
  static const surface = Color(0xFF0C1D1F);
  static const text    = Color(0xFFEDF7F4);
  static const muted   = Color(0xFFA8C4BF);
  static const faint   = Color(0xFF3D5C58);
  static const teal    = Color(0xFF1EC9B8);
  static const teal2   = Color(0xFF58DAD0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p           = widget.profile;
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Scrollable body ──────────────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 130 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero banner
                  _ProfileHero(
                    profile: p,
                    topInset: topInset,
                    onBack: () => Navigator.of(context).pop(),
                  ),

                  // White-rounded content area overlapping the hero bottom
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag nub
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 10, bottom: 4),
                              width: 42,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),

                          // ── Stats ────────────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Row(
                              children: [
                                _StatBox(value: '${p.tripCount}',  label: 'Trips'),
                                const SizedBox(width: 10),
                                _StatBox(value: '${p.rating}',     label: 'Rating'),
                                const SizedBox(width: 10),
                                _StatBox(value: '${p.buddyCount}', label: 'Buddies'),
                              ],
                            ),
                          ),

                          // ── About ────────────────────────────────────────
                          const _SectionTitle('About'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              p.bio,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 13,
                                height: 1.7,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: p.vibes
                                  .map((e) => _VibeChip(label: e))
                                  .toList(),
                            ),
                          ),

                          // ── Active trip ──────────────────────────────────
                          const _SectionTitle('Active Trip'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: teal.withOpacity(.14),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: teal.withOpacity(.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.flight_takeoff_rounded,
                                        color: teal2,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.activeTripName,
                                          style: const TextStyle(
                                            color: text,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${p.activeTripDates} · ${p.activeTripLooking}',
                                          style: const TextStyle(
                                            color: muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: teal.withOpacity(.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Live',
                                      style: TextStyle(
                                        color: teal2,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Moments (gallery) ────────────────────────────
                          const _SectionTitle('Moments'),
                          SizedBox(
                            height: 130,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: p.gallery.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                              itemBuilder: (_, i) => _MomentCard(
                                label: p.gallery[i],
                                color: p.avatarColor,
                              ),
                            ),
                          ),

                          // ── Travel log ───────────────────────────────────
                          const _SectionTitle('Travel Log'),
                          SizedBox(
                            height: 96,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: p.travelLog.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                              itemBuilder: (_, i) {
                                final e = p.travelLog[i];
                                return Container(
                                  width: 112,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(.06),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        e.emoji,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        e.destination,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: text,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        e.companions,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: faint,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // ── Reviews ──────────────────────────────────────
                          if (p.reviews.isNotEmpty) ...[
                            const _SectionTitle('Reviews'),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                children: p.reviews
                                    .map(
                                      (r) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: surface,
                                        borderRadius:
                                        BorderRadius.circular(18),
                                        border: Border.all(
                                          color: Colors.white
                                              .withOpacity(.06),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: teal2
                                                      .withOpacity(.14),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    r.initial,
                                                    style: const TextStyle(
                                                      color: teal2,
                                                      fontSize: 13,
                                                      fontWeight:
                                                      FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    r.name,
                                                    style: const TextStyle(
                                                      color: text,
                                                      fontSize: 13,
                                                      fontWeight:
                                                      FontWeight.w700,
                                                    ),
                                                  ),
                                                  Text(
                                                    r.tripLabel,
                                                    style: const TextStyle(
                                                      color: faint,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            r.text,
                                            style: const TextStyle(
                                              color: muted,
                                              fontSize: 12,
                                              height: 1.65,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                    .toList(),
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Fixed bottom CTA ─────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomCta(
              profile: p,
              showForm: _showRequestForm,
              msgCtrl: _msgCtrl,
              onAskToJoin: () => setState(() => _showRequestForm = true),
              onDismiss: () => setState(() => _showRequestForm = false),
              onSend: () => Navigator.of(context).pop(),
              bottomInset: bottomInset,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero banner
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  final UserProfileData profile;
  final double topInset;
  final VoidCallback onBack;

  const _ProfileHero({
    required this.profile,
    required this.topInset,
    required this.onBack,
  });

  static const text  = Color(0xFFEDF7F4);
  static const muted = Color(0xFFA8C4BF);
  static const gold  = Color(0xFFF7B84E);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed colour gradient using avatar colour as the hero tone
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  profile.avatarColor.withOpacity(.95),
                  const Color(0xFF10191A),
                  const Color(0xFF070E0F),
                ],
                stops: const [0.0, 0.65, 1.0],
              ),
            ),
          ),

          // Radial ambient glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.1,
                  colors: [
                    profile.avatarColor.withOpacity(.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: topInset + 12,
            left: 16,
            child: _GlassIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),
          ),

          // More button
          Positioned(
            top: topInset + 12,
            right: 16,
            child: const _GlassIconButton(icon: Icons.more_horiz_rounded),
          ),

          // Avatar + name centred in the lower half
          Positioned(
            left: 20,
            right: 20,
            bottom: 36,
            child: Column(
              children: [
                // Avatar ring
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(.35),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.22),
                        blurRadius: 32,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(.18),
                    ),
                    child: Center(
                      child: Text(
                        profile.avatarInitial,
                        style: const TextStyle(
                          color: text,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name + verified badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${profile.name}, ${profile.age}',
                      style: const TextStyle(
                        color: text,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF58DAD0),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '✓',
                          style: TextStyle(
                            color: Color(0xFF041818),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Location
                Text(
                  '📍 Based in ${profile.basedIn}',
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
                const SizedBox(height: 10),

                // Rating pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(.14),
                    ),
                  ),
                  child: Text(
                    '⭐ ${profile.rating} · ${profile.tripCount} trips',
                    style: const TextStyle(
                      color: gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass icon button (back / more)
// ─────────────────────────────────────────────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _GlassIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.14)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Moment card (gallery strip)
// ─────────────────────────────────────────────────────────────────────────────

class _MomentCard extends StatelessWidget {
  final String label;
  final Color color;

  const _MomentCard({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(.85), const Color(0xFF152224)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            bottom: 12,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat box
// ─────────────────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1D1F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.06)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFEDF7F4),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF3D5C58), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vibe chip
// ─────────────────────────────────────────────────────────────────────────────

class _VibeChip extends StatelessWidget {
  final String label;

  const _VibeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1D1F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFA8C4BF),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFEDF7F4),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom CTA
// ─────────────────────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  final UserProfileData profile;
  final bool showForm;
  final TextEditingController msgCtrl;
  final VoidCallback onAskToJoin;
  final VoidCallback onDismiss;
  final VoidCallback onSend;
  final double bottomInset;

  const _BottomCta({
    required this.profile,
    required this.showForm,
    required this.msgCtrl,
    required this.onAskToJoin,
    required this.onDismiss,
    required this.onSend,
    required this.bottomInset,
  });

  static const teal  = Color(0xFF1EC9B8);
  static const teal2 = Color(0xFF58DAD0);
  static const faint = Color(0xFF3D5C58);
  static const text  = Color(0xFFEDF7F4);
  static const muted = Color(0xFFA8C4BF);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF070E0F),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(.07)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.45),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: showForm
          ? Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: muted, fontSize: 13),
                    children: [
                      const TextSpan(text: 'Asking to join '),
                      TextSpan(
                        text: profile.activeTripName,
                        style: const TextStyle(
                          color: teal2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text:
                        '. Introduce yourself to ${profile.name}!',
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(
                  Icons.close_rounded,
                  color: faint,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C1D1F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(.07)),
            ),
            child: TextField(
              controller: msgCtrl,
              maxLines: 3,
              style: const TextStyle(color: text, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Your message...',
                hintStyle: TextStyle(color: faint, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSend,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: teal.withOpacity(.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Send Request',
                  style: TextStyle(
                    color: Color(0xFF041818),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Messaging unlocks if ${profile.name} accepts',
            textAlign: TextAlign.center,
            style: const TextStyle(color: faint, fontSize: 12),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onAskToJoin,
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
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Ask to Join Trip',
                  style: TextStyle(
                    color: Color(0xFF041818),
                    fontSize: 16,
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