// lib/features/profile/screens/my_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/nav_provider.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../home/widgets/home_bottom_nav.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  static const _bg      = Color(0xFF070E0F);
  static const _surface = Color(0xFF0D1819);
  static const _teal    = Color(0xFF1EC9B8);
  static const _teal2   = Color(0xFF58DAD0);
  static const _gold    = Color(0xFFF7B84E);
  static const _text    = Color(0xFFEDF7F4);
  static const _muted   = Color(0xFFA8C4BF);
  static const _faint   = Color(0xFF6A8882);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bottomNavIndexProvider.notifier).setIndex(4);
    });
  }

  Future<void> _openEdit(BuildContext context) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => const EditProfileScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                    .animate(curved),
            child: child,
          );
        },
      ),
    );
    ref.read(myProfileProvider.notifier).refresh();
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/login');
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _SettingsSheet(
        onNotifications: () {
          Navigator.of(sheetCtx).pop();
          context.go('/notifications');
        },
        onPrivacy: () {
          Navigator.of(sheetCtx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Privacy settings coming soon!')),
          );
        },
        onHelp: () {
          Navigator.of(sheetCtx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Help center coming soon!')),
          );
        },
        onSignOut: () {
          Navigator.of(sheetCtx).pop();
          _signOut(context);
        },
      ),
    );
  }

  void _showLinkedAccounts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: Color(0xFF0D1819),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Linked Accounts',
              style: TextStyle(
                color: _text, fontSize: 18, fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _SheetRow(
              icon: Icons.camera_alt_outlined,
              title: 'Instagram',
              subtitle: 'Connect to show your handle',
              onTap: () {
                Navigator.of(sheetCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Instagram linking coming soon!')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTravelLog(BuildContext context, int tripCount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: Color(0xFF0D1819),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Travel Log',
              style: TextStyle(
                color: _text, fontSize: 18, fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            if (tripCount == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.luggage_rounded,
                          color: Color(0xFF6A8882), size: 40),
                      SizedBox(height: 12),
                      Text(
                        'No trips yet',
                        style: TextStyle(color: Color(0xFF6A8882), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                '$tripCount past trip${tripCount == 1 ? '' : 's'} completed.',
                style: const TextStyle(color: _muted, fontSize: 14),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEndorsements(BuildContext context, double rating, int reviewCount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: Color(0xFF0D1819),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Endorsements',
              style: TextStyle(
                color: _text, fontSize: 18, fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            if (reviewCount == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.star_border_rounded,
                          color: Color(0xFF6A8882), size: 40),
                      SizedBox(height: 12),
                      Text(
                        'No reviews yet',
                        style: TextStyle(color: Color(0xFF6A8882), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: _gold, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '${rating.toStringAsFixed(1)} avg from $reviewCount review${reviewCount == 1 ? '' : 's'}',
                    style: const TextStyle(color: _muted, fontSize: 14),
                  ),
                ],
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showBuddies(BuildContext context, int buddyCount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: const BoxDecoration(
          color: Color(0xFF0D1819),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Travel Buddies',
              style: TextStyle(
                color: _text, fontSize: 18, fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            if (buddyCount == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          color: Color(0xFF6A8882), size: 40),
                      SizedBox(height: 12),
                      Text(
                        'No buddies yet — start exploring!',
                        style: TextStyle(color: Color(0xFF6A8882), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                '$buddyCount travel buddy${buddyCount == 1 ? '' : ' connections'}.',
                style: const TextStyle(color: _muted, fontSize: 14),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  double _computeTrustScore(profile) {
    double score = 0.0;
    if (profile == null) return score;
    if ((profile.name ?? '').isNotEmpty) score += 0.20;
    if ((profile.avatarUrl ?? '').isNotEmpty) score += 0.20;
    if ((profile.bio ?? '').isNotEmpty) score += 0.15;
    if ((profile.baseCity ?? '').isNotEmpty) score += 0.10;
    if ((profile.vibes as List).isNotEmpty) score += 0.10;
    if (profile.tripCount > 0) score += 0.15;
    if (profile.buddyCount > 0) score += 0.10;
    return score.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final topInset        = MediaQuery.of(context).padding.top;
    final bottomInset     = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 88.0 + bottomInset;
    final profileAsync    = ref.watch(myProfileProvider);

    final authUser = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      extendBody: true,
      body: Stack(
        children: [
          // Radial glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.8, -1),
                  radius: 1.1,
                  colors: [Color(0x201EC9B8), Colors.transparent],
                ),
              ),
            ),
          ),

          // Scrollable content
          Positioned(
            top: 0, left: 0, right: 0,
            bottom: bottomNavHeight,
            child: profileAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1EC9B8), strokeWidth: 2,
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFF6A8882), size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load profile',
                      style: TextStyle(color: _faint, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () =>
                          ref.read(myProfileProvider.notifier).refresh(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _teal.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Retry',
                            style: TextStyle(
                                color: _teal2, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              data: (profile) {
                final name = (profile?.name ?? '').isNotEmpty
                    ? profile!.name!
                    : (authUser?.email?.split('@').first ?? 'Traveler');
                final avatarUrl   = profile?.avatarUrl;
                final tripCount   = profile?.tripCount ?? 0;
                final buddyCount  = profile?.buddyCount ?? 0;
                final rating      = profile?.rating ?? 0.0;
                final reviewCount = (rating > 0 && tripCount > 0) ? tripCount : 0;
                final trustScore  = _computeTrustScore(profile);
                final age         = profile?.age;
                final displayName = age != null ? '$name, $age' : name;

                return SingleChildScrollView(
                  padding: EdgeInsets.only(top: topInset, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row ──────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Profile',
                                style: TextStyle(
                                  color: _text,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.3,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _openEdit(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _teal.withOpacity(.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: _teal2,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _showSettings(context),
                              child: Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.settings_outlined,
                                  color: _faint, size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── User header ─────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // ── Avatar: UserAvatar widget (Google photo / initials) ──
                            GestureDetector(
                              onTap: () => _openEdit(context),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  UserAvatar(
                                    size: 74,
                                    avatarUrl: avatarUrl,
                                    displayName: name,
                                    borderRadius: 22,
                                  ),
                                  // Camera badge
                                  Positioned(
                                    bottom: 0, right: 0,
                                    child: Container(
                                      width: 22, height: 22,
                                      decoration: BoxDecoration(
                                        color: _teal,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.black,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      color: _text,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if ((profile?.baseCity ?? '').isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: _faint, size: 13,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          profile!.baseCity!,
                                          style: const TextStyle(
                                            color: _faint, fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    GestureDetector(
                                      onTap: () => _openEdit(context),
                                      child: const Row(
                                        children: [
                                          Text(
                                            'Add your location',
                                            style: TextStyle(
                                              color: _faint, fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(width: 2),
                                          Icon(Icons.chevron_right_rounded,
                                              color: _faint, size: 15),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _StatPill(
                                        label: 'Trips',
                                        value: '$tripCount',
                                        onTap: () =>
                                            _showTravelLog(context, tripCount),
                                      ),
                                      const SizedBox(width: 8),
                                      _StatPill(
                                        label: 'Buddies',
                                        value: '$buddyCount',
                                        onTap: () =>
                                            _showBuddies(context, buddyCount),
                                      ),
                                      if (rating > 0) ...[
                                        const SizedBox(width: 8),
                                        _StatPill(
                                          label: '★',
                                          value: rating.toStringAsFixed(1),
                                          onTap: () => _showEndorsements(
                                              context, rating, reviewCount),
                                          accent: _gold,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Bio ─────────────────────────────────────────────
                      if ((profile?.bio ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Text(
                            profile!.bio!,
                            style: const TextStyle(
                              color: _muted, fontSize: 14, height: 1.5,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: GestureDetector(
                            onTap: () => _openEdit(context),
                            child: const Text(
                              'Add a bio so travelers know who you are →',
                              style: TextStyle(
                                  color: _faint, fontSize: 13,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),

                      // ── Vibes chips ──────────────────────────────────────
                      if ((profile?.vibes ?? []).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Wrap(
                            spacing: 8, runSpacing: 8,
                            children: (profile!.vibes).map((v) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _teal.withOpacity(.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: _teal.withOpacity(.20)),
                                ),
                                child: Text(
                                  v,
                                  style: const TextStyle(
                                      color: _teal2, fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      // ── Trust Score card ─────────────────────────────────
                      _TrustCard(
                        score: trustScore,
                        onLinkId: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Government ID linking coming soon!')),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Primary menu group ───────────────────────────────
                      _MenuGroup(
                        items: [
                          _MenuItem(
                            emoji: '📍',
                            title: 'Travel Log',
                            subtitle:
                                '$tripCount Past Trip${tripCount == 1 ? '' : 's'}',
                            onTap: () => _showTravelLog(context, tripCount),
                          ),
                          _MenuItem(
                            emoji: '⭐',
                            title: 'Endorsements',
                            subtitle: reviewCount == 0
                                ? 'No reviews yet'
                                : '$reviewCount Review${reviewCount == 1 ? '' : 's'} (${rating.toStringAsFixed(1)} avg)',
                            onTap: () => _showEndorsements(
                                context, rating, reviewCount),
                          ),
                          _MenuItem(
                            emoji: '🤝',
                            title: 'Travel Buddies',
                            subtitle:
                                '$buddyCount Connection${buddyCount == 1 ? '' : 's'}',
                            onTap: () => _showBuddies(context, buddyCount),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Secondary menu group ─────────────────────────────
                      _MenuGroup(
                        items: [
                          _MenuItem(
                            icon: Icons.camera_alt_outlined,
                            title: 'Linked Accounts',
                            trailingLabel: 'Instagram',
                            onTap: () => _showLinkedAccounts(context),
                          ),
                          _MenuItem(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            onTap: () => _showSettings(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom nav
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

// ─── Stat Pill ────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color? accent;

  const _StatPill({
    required this.label,
    required this.value,
    required this.onTap,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? const Color(0xFF58DAD0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF6A8882), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trust Score card ─────────────────────────────────────────────────────────

class _TrustCard extends StatelessWidget {
  final double score;
  final VoidCallback onLinkId;
  const _TrustCard({required this.score, required this.onLinkId});

  static const _gold = Color(0xFFF7B84E);
  static const _text = Color(0xFFEDF7F4);

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [_gold.withOpacity(.10), Colors.transparent],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gold.withOpacity(.20)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_rounded, color: _gold, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Trust Score',
                      style: TextStyle(
                          color: _gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Text(
                  '$pct%',
                  style: const TextStyle(
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 6,
                color: Colors.black.withOpacity(.40),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: score,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Link Govt. ID for Priority',
                  style: TextStyle(color: _text, fontSize: 12),
                ),
                GestureDetector(
                  onTap: onLinkId,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      '+25%',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Menu group ───────────────────────────────────────────────────────────────

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(.05)),
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            return Column(
              children: [
                items[i],
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.white.withOpacity(.05),
                    indent: 16, endIndent: 16,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String? emoji;
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? trailingLabel;
  final VoidCallback onTap;

  const _MenuItem({
    this.emoji,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailingLabel,
    required this.onTap,
  });

  static const _text  = Color(0xFFEDF7F4);
  static const _faint = Color(0xFF6A8882);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: icon != null
                    ? Icon(icon, color: _faint, size: 18)
                    : Text(emoji ?? '', style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: _text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: const TextStyle(
                            color: _faint, fontSize: 12)),
                  ],
                ],
              ),
            ),
            if (trailingLabel != null)
              Text(trailingLabel!,
                  style: const TextStyle(color: _text, fontSize: 13))
            else
              const Icon(Icons.chevron_right_rounded,
                  color: _faint, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Settings sheet ───────────────────────────────────────────────────────────

class _SettingsSheet extends StatelessWidget {
  final VoidCallback onNotifications;
  final VoidCallback onPrivacy;
  final VoidCallback onHelp;
  final VoidCallback onSignOut;

  const _SettingsSheet({
    required this.onNotifications,
    required this.onPrivacy,
    required this.onHelp,
    required this.onSignOut,
  });

  static const _text  = Color(0xFFEDF7F4);
  static const _faint = Color(0xFF6A8882);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1819),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Settings',
            style: TextStyle(
                color: _text, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          _SheetRow(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage alerts',
            onTap: onNotifications,
          ),
          const SizedBox(height: 8),
          _SheetRow(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            subtitle: 'Who can see your profile',
            onTap: onPrivacy,
          ),
          const SizedBox(height: 8),
          _SheetRow(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: onHelp,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(.07)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onSignOut,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.logout_rounded,
                        color: Colors.redAccent, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Sign Out',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet row ────────────────────────────────────────────────────────────────

class _SheetRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SheetRow({
    this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  static const _text  = Color(0xFFEDF7F4);
  static const _faint = Color(0xFF6A8882);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon ?? Icons.circle_outlined,
                    color: _faint, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: _text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            color: _faint, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _faint, size: 18),
          ],
        ),
      ),
    );
  }
}
