import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/nav_provider.dart';
import '../../trips/screens/create_trip_sheet.dart';

class HomeBottomNav extends ConsumerWidget {
  const HomeBottomNav({super.key});

  static const _left = [
    (icon: Icons.home_rounded,    label: 'Home',    route: '/home',    extra: null),
    (icon: Icons.explore_rounded, label: 'Explore', route: '/explore', extra: null),
  ];
  static const _right = [
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chats',   route: '/chat',    extra: null),
    (icon: Icons.person_outline_rounded,      label: 'Profile', route: '/profile', extra: null),
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
        children: [
          ..._left.asMap().entries.map((e) => GestureDetector(
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).setIndex(e.key);
              context.go(e.value.route, extra: e.value.extra);
            },
            child: _NavItem(
              icon: e.value.icon,
              label: e.value.label,
              active: activeIndex == e.key,
            ),
          )),

          GestureDetector(
            onTap: () => CreateTripSheet.show(context),
            child: Container(
              width: 44, height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1EC9B8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1EC9B8).withOpacity(.35),
                    blurRadius: 16, offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Color(0xFF041818), size: 24),
            ),
          ),

          ..._right.asMap().entries.map((e) {
            final globalIndex = e.key + 3;
            return GestureDetector(
              onTap: () {
                ref.read(bottomNavIndexProvider.notifier).setIndex(globalIndex);
                context.go(e.value.route, extra: e.value.extra);
              },
              child: _NavItem(
                icon: e.value.icon,
                label: e.value.label,
                active: activeIndex == globalIndex,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({required this.icon, required this.label, this.active = false});

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