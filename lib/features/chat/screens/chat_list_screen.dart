// lib/features/chat/screens/chats_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/nav_provider.dart';
import '../../home/widgets/home_bottom_nav.dart';
import '../models/chat_preview.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bottomNavIndexProvider.notifier).setIndex(3);
    });
  }

  static const _bg      = Color(0xFF081314);
  static const _surface = Color(0xFF0C1D1F);
  static const _teal    = Color(0xFF1EC9B8);
  static const _teal2   = Color(0xFF58DAD0);
  static const _text    = Color(0xFFEDF7F4);
  static const _muted   = Color(0xFF8AADA8);
  static const _faint   = Color(0xFF3D5C58);

  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Content ──────────────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Chats',
                          style: TextStyle(
                            color: _text,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      // New chat icon
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: _teal.withOpacity(.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _teal.withOpacity(.2)),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: _teal2,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(.06)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(Icons.search_rounded, color: _muted, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: TextField(
                            style: TextStyle(color: _text, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search conversations...',
                              hintStyle: TextStyle(color: Color(0xFF3D5C58), fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Active now row (stories-style)
              SliverToBoxAdapter(
                child: _ActiveNowRow(chats: mockChatPreviews.where((c) => c.isOnline).toList()),
              ),

              // Section label
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'Recent',
                    style: TextStyle(
                      color: Color(0xFF3D5C58),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

              // Chat list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final chat = mockChatPreviews[index];
                    return _ChatRow(
                      chat: chat,
                      onTap: () => context.go('/chat/${chat.id}'),
                    );
                  },
                  childCount: mockChatPreviews.length,
                ),
              ),

              // Bottom padding for nav bar
              SliverToBoxAdapter(
                child: SizedBox(height: 100 + bottomInset),
              ),
            ],
          ),

          // ── Bottom nav ───────────────────────────────────────────────────
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

// ── Active Now horizontal strip ───────────────────────────────────────────────

class _ActiveNowRow extends StatelessWidget {
  final List<ChatPreview> chats;
  const _ActiveNowRow({required this.chats});

  static const _teal2 = Color(0xFF58DAD0);
  static const _muted = Color(0xFF8AADA8);

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Text(
            'Active now',
            style: TextStyle(
              color: Color(0xFF3D5C58),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: chats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final c = chats[i];
              return GestureDetector(
                onTap: () => context.go('/chat/${c.id}'),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        _AvatarCircle(
                          initial: c.avatarInitial,
                          color: Color(int.parse(c.avatarColor)),
                          size: 52,
                        ),
                        Positioned(
                          bottom: 2, right: 2,
                          child: Container(
                            width: 12, height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF081314), width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.name,
                      style: const TextStyle(
                        color: _muted, fontSize: 11, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Single chat row ───────────────────────────────────────────────────────────

class _ChatRow extends StatelessWidget {
  final ChatPreview chat;
  final VoidCallback onTap;
  const _ChatRow({required this.chat, required this.onTap});

  static const _text    = Color(0xFFEDF7F4);
  static const _muted   = Color(0xFF8AADA8);
  static const _faint   = Color(0xFF3D5C58);
  static const _teal    = Color(0xFF1EC9B8);
  static const _teal2   = Color(0xFF58DAD0);
  static const _surface = Color(0xFF0C1D1F);

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(chat.avatarColor));
    final hasUnread = chat.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasUnread ? _surface : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: hasUnread
              ? Border.all(color: _teal.withOpacity(.12))
              : null,
        ),
        child: Row(
          children: [
            // Avatar + online dot
            Stack(
              children: [
                _AvatarCircle(initial: chat.avatarInitial, color: color, size: 50),
                if (chat.isOnline)
                  Positioned(
                    bottom: 2, right: 2,
                    child: Container(
                      width: 11, height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF081314), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name + message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: TextStyle(
                            color: _text,
                            fontSize: 15,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        chat.time,
                        style: TextStyle(
                          color: hasUnread ? _teal2 : _faint,
                          fontSize: 11,
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Destination chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '✈ ${chat.destination}',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            color: hasUnread ? _muted : _faint,
                            fontSize: 13,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${chat.unreadCount}',
                              style: const TextStyle(
                                color: Color(0xFF041818),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
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
    );
  }
}

// ── Shared avatar ─────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  final String initial;
  final Color color;
  final double size;
  const _AvatarCircle({required this.initial, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(.18),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(.35), width: 1.5),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}