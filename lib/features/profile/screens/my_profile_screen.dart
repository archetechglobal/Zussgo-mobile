// lib/features/profile/screens/my_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/nav_provider.dart';
import '../../home/widgets/home_bottom_nav.dart';
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

  // Mock current user data
  static const _userName    = 'Aryan';
  static const _userBase    = 'Mumbai, India';
  static const _userBio     = 'Designer by day, avoiding reality by weekend.';
  static const _trustScore  = 0.75;
  static const _rating      = 4.9;
  static const _tripCount   = 8;
  static const _reviewCount = 4;
  static const _photoUrl    =
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop';

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

  void _openEdit() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => const EditProfileScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation, curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1), end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 88.0 + bottomInset;

    return Scaffold(
      backgroundColor: _bg,
      extendBody: true,
      body: Stack(
        children: [
          // Subtle radial glow top-left
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

          // ── Scrollable content ────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            bottom: bottomNavHeight,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: topInset, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Header row ─────────────────────────────────────────
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
                          onTap: _openEdit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8,
                            ),
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
                      ],
                    ),
                  ),

                  // ── User header ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Row(
                      children: [
                        // Avatar — rounded square with photo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            _photoUrl,
                            width: 70, height: 70, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 70, height: 70,
                              color: _teal.withOpacity(.2),
                              child: const Center(
                                child: Text('A', style: TextStyle(
                                  color: _teal2, fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                )),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                _userName,
                                style: TextStyle(
                                  color: _text,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // "View Public Profile →"
                              GestureDetector(
                                onTap: () {}, // preview own public profile
                                child: Row(
                                  children: [
                                    const Text(
                                      'View Public Profile',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: _muted, size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Trust Score card ────────────────────────────────────
                  _TrustCard(score: _trustScore),

                  const SizedBox(height: 24),

                  // ── Primary menu group ──────────────────────────────────
                  _MenuGroup(
                    items: [
                      _MenuItem(
                        emoji: '📍',
                        title: 'Travel Log',
                        subtitle: '$_tripCount Past Trips',
                        onTap: () {},
                      ),
                      _MenuItem(
                        emoji: '⭐',
                        title: 'Endorsements',
                        subtitle:
                        '$_reviewCount Reviews ($_rating Avg)',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Secondary menu group ────────────────────────────────
                  _MenuGroup(
                    items: [
                      _MenuItem(
                        svgIcon: _InstagramIcon(),
                        title: 'Linked Accounts',
                        trailingLabel: 'Instagram',
                        onTap: () {},
                      ),
                      _MenuItem(
                        svgIcon: _SettingsIcon(),
                        title: 'Settings',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Bottom nav ────────────────────────────────────────────────────
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

// ─── Trust Score card ─────────────────────────────────────────────────────────

class _TrustCard extends StatelessWidget {
  final double score; // 0.0 – 1.0
  const _TrustCard({required this.score});

  static const _gold   = Color(0xFFF7B84E);
  static const _text   = Color(0xFFEDF7F4);
  static const _faint  = Color(0xFF6A8882);

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
            // Top row: label + score %
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_rounded, color: _gold, size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'Trust Score',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$pct%',
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
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

            // Bottom action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Link Govt. ID for Priority',
                  style: TextStyle(color: _text, fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '+25%',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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
  final Widget? svgIcon;
  final String title;
  final String? subtitle;
  final String? trailingLabel;
  final VoidCallback onTap;

  const _MenuItem({
    this.emoji,
    this.svgIcon,
    required this.title,
    this.subtitle,
    this.trailingLabel,
    required this.onTap,
  });

  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);
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
            // Icon box
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: svgIcon != null
                    ? svgIcon!
                    : Text(emoji ?? '', style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 14),
            // Title + optional subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                    color: _text, fontSize: 14, fontWeight: FontWeight.w600,
                  )),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: const TextStyle(
                      color: _faint, fontSize: 12,
                    )),
                  ],
                ],
              ),
            ),
            // Trailing: label or chevron
            if (trailingLabel != null)
              Text(trailingLabel!, style: const TextStyle(
                color: _text, fontSize: 13,
              ))
            else
              Icon(Icons.chevron_right_rounded, color: _faint, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Icon widgets ─────────────────────────────────────────────────────────────

class _InstagramIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.camera_alt_outlined,
        color: const Color(0xFF6A8882), size: 18);
  }
}

class _SettingsIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.settings_outlined,
        color: const Color(0xFF6A8882), size: 18);
  }
}