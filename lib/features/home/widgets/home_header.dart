// lib/features/home/widgets/home_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/widgets/user_profile_sheet.dart';
import '../providers/home_provider.dart';

class HomeHeader extends ConsumerStatefulWidget {
  final double topInset;
  const HomeHeader({super.key, required this.topInset});

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _focused = false;

  static const _text  = Color(0xFFEAF7F3);
  static const _faint = Color(0xFF6A8882);
  static const _teal  = Color(0xFF20C9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _gold  = Color(0xFFF7B84E);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode  = FocusNode();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _onChanged(String value) {
    ref.read(homeSearchQueryProvider.notifier).state = value.trim();
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(homeSearchQueryProvider.notifier).state = '';
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final unread       = ref.watch(unreadCountProvider);
    final profileAsync = ref.watch(myProfileProvider);
    final query        = ref.watch(homeSearchQueryProvider);

    final profile   = profileAsync.asData?.value;
    final firstName = (profile?.name ?? 'Traveler').split(' ').first;
    final initial   = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'Z';
    final avatarUrl = profile?.avatarUrl;

    final hasQuery  = query.isNotEmpty;
    final borderColor = hasQuery
        ? _teal.withOpacity(.55)
        : (_focused ? _teal.withOpacity(.35) : _teal.withOpacity(.18));

    return Padding(
      padding: EdgeInsets.fromLTRB(16, widget.topInset + 10, 16, 0),
      child: Column(
        children: [
          // ── Top row: greeting + bell + avatar ──────────────────────────────
          Row(
            children: [
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

              // Bell
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: _text, size: 22),
                    ),
                    if (unread > 0)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          width: 17, height: 17,
                          decoration: BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0B1516), width: 2),
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

              // Avatar
              GestureDetector(
                onTap: () => UserProfileSheet.show(context, name: firstName),
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: avatarUrl == null
                        ? const LinearGradient(colors: [_teal2, _teal, _gold])
                        : null,
                  ),
                  child: avatarUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            avatarUrl, width: 42, height: 42, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _InitialAvatar(initial: initial),
                          ),
                        )
                      : _InitialAvatar(initial: initial),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Search bar (live TextField) ─────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xE00D1819),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: hasQuery
                  ? [BoxShadow(color: _teal.withOpacity(.08), blurRadius: 12, spreadRadius: 0)]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  hasQuery ? Icons.place_rounded : Icons.search_rounded,
                  color: hasQuery ? _teal2 : _faint.withOpacity(.95),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onChanged,
                    style: TextStyle(
                      color: hasQuery ? _text : _faint,
                      fontSize: 13,
                      fontWeight: hasQuery ? FontWeight.w600 : FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Where are you headed?',
                      hintStyle: TextStyle(
                        color: _faint,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _focusNode.unfocus(),
                  ),
                ),

                // Clear button when query is active, AI pill otherwise
                if (hasQuery)
                  GestureDetector(
                    onTap: _clearSearch,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _faint.withOpacity(.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, color: _faint, size: 14),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          color: Color(0xFF041818), fontSize: 15, fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
