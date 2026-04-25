import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/nav_provider.dart';

// ─── Nav config ──────────────────────────────────────────────────────────────
// 5 tabs. Centre slot is Match — navigates to /match on tap,
// opens CreateTripSheet on long-press. A small "+" badge on the centre
// icon communicates the dual function without crowding the bar.

class HomeBottomNav extends ConsumerWidget {
  const HomeBottomNav({super.key});

  static const _items = [
    (icon: Icons.home_rounded,              label: 'Home',    route: '/home',    idx: 0),
    (icon: Icons.explore_rounded,           label: 'Explore', route: '/explore', idx: 1),
    (icon: Icons.favorite_outline_rounded,  label: 'Match',   route: '/match',   idx: 2),
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chats', route: '/chat',    idx: 3),
    (icon: Icons.person_outline_rounded,    label: 'Profile', route: '/profile', idx: 4),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(bottomNavIndexProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1819),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _items.map((item) {
          final isCentre = item.idx == 2;
          final isActive = active == item.idx;

          if (isCentre) {
            return _CentreTab(
              isActive: isActive,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(bottomNavIndexProvider.notifier).setIndex(item.idx);
                context.go(item.route);
              },
            );
          }

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(bottomNavIndexProvider.notifier).setIndex(item.idx);
              context.go(item.route);
            },
            child: _NavItem(
              icon: item.icon,
              label: item.label,
              active: isActive,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Centre Match tab ─────────────────────────────────────────────────────────
// Tap → Match screen. Long press → Create Trip sheet.
// Visually: teal pill with heart icon. Small "+" badge top-right signals
// the long-press action without adding a 6th nav item.

class _CentreTab extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CentreTab({
    required this.isActive,
    required this.onTap,
  });

  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _dark  = Color(0xFF041818);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Main pill button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52, height: 32,
                decoration: BoxDecoration(
                  color: isActive ? _teal : _teal.withOpacity(.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? Colors.transparent
                        : _teal.withOpacity(.35),
                  ),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: _teal.withOpacity(.40),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ] : [],
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 17,
                    color: isActive ? _dark : _teal2,
                  ),
                ),
              ),

              // Small "+" badge — signals long-press creates a trip
              Positioned(
                top: -4, right: -4,
                child: Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(.90)
                        : _teal.withOpacity(.80),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0C1819), width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 9,
                      color: isActive ? _dark : _dark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Match',
            style: TextStyle(
              color: isActive ? _teal2 : const Color(0xFF6D8B86),
              fontSize: 10, fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Standard nav item ────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    const teal2 = Color(0xFF58DAD0);
    const faint = Color(0xFF6D8B86);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? teal2.withOpacity(.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: active ? teal2 : faint),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: active ? teal2 : faint,
            fontSize: 10, fontWeight: FontWeight.w800,
          )),
        ],
      ),
    );
  }
}