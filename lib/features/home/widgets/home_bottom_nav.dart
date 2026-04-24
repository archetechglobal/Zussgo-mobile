// lib/features/home/widgets/home_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/nav_provider.dart';

class HomeBottomNav extends ConsumerWidget {
  const HomeBottomNav({super.key});

  static const _items = [
    (icon: Icons.home_rounded,                label: 'Home',    route: '/home',    extra: null),
    (icon: Icons.explore_rounded,             label: 'Explore', route: '/home',    extra: null), // placeholder until ExploreScreen exists
    (icon: Icons.favorite_outline_rounded,    label: 'Match',   route: '/match',   extra: 'discover'),
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chats',   route: '/home',    extra: null), // placeholder
    (icon: Icons.person_outline_rounded,      label: 'Profile', route: '/home',    extra: null), // placeholder
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(bottomNavIndexProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1819),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          return GestureDetector(
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).setIndex(i);
              context.go(item.route, extra: item.extra);
            },
            child: _BottomItem(
              icon: item.icon,
              label: item.label,
              active: activeIndex == i,
            ),
          );
        }),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomItem({
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
          Text(
            label,
            style: TextStyle(
              color: active ? teal2 : faint,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}