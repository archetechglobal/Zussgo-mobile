// lib/features/home/widgets/home_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/widgets/user_profile_sheet.dart';

class HomeHeader extends ConsumerWidget {
  final double topInset;
  const HomeHeader({super.key, required this.topInset});

  static const _text  = Color(0xFFEAF7F3);
  static const _faint = Color(0xFF6A8882);
  static const _teal  = Color(0xFF20C9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _gold  = Color(0xFFF7B84E);

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread       = ref.watch(unreadCountProvider);
    final profileAsync = ref.watch(myProfileProvider);

    final profile   = profileAsync.asData?.value;
    final firstName = (profile?.name ?? 'Traveler').split(' ').first;
    final initial   = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'Z';
    final avatarUrl = profile?.avatarUrl;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topInset + 10, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              // Greeting & name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: const TextStyle(
                      color: Color(0x99EAF7F3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hey, $firstName',
                    style: const TextStyle(
                      color: _text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // ──────────────────────────────────────────────────
              // Notification bell icon (with unread badge)
              // ──────────────────────────────────────────────────
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: _text,
                        size: 22,
                      ),
                    ),
                    if (unread > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0B1516),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              style: const TextStyle(
                                color: Color(0xFF041818),
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ──────────────────────────────────────────────────
              // Avatar (opens profile sheet)
              // ──────────────────────────────────────────────────
              GestureDetector(
                onTap: () => UserProfileSheet.show(context, name: firstName),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: avatarUrl == null
                        ? const LinearGradient(
                      colors: [_teal2, _teal, _gold],
                    )
                        : null,
                  ),
                  child: avatarUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      avatarUrl,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _InitialAvatar(initial: initial),
                    ),
                  )
                      : _InitialAvatar(initial: initial),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xE00D1819),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _teal.withOpacity(.18)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: _faint.withOpacity(.95),
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Where are you headed?',
                    style: TextStyle(
                      color: _faint,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _teal.withOpacity(.18)),
                  ),
                  child: const Text(
                    '✶ AI Match',
                    style: TextStyle(
                      color: _teal2,
                      fontSize: 10,
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

class _InitialAvatar extends StatelessWidget {
  final String initial;
  const _InitialAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF041818),
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
