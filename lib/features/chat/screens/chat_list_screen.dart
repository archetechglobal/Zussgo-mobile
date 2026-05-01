// lib/features/chat/screens/chats_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/nav_provider.dart';
import '../../home/widgets/home_bottom_nav.dart';
import '../providers/chat_provider.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  static const _bg      = Color(0xFF081314);
  static const _surface = Color(0xFF0C1D1F);
  static const _teal    = Color(0xFF1EC9B8);
  static const _teal2   = Color(0xFF58DAD0);
  static const _text    = Color(0xFFEDF7F4);
  static const _muted   = Color(0xFF8AADA8);
  static const _faint   = Color(0xFF3D5C58);

  final _searchCtrl = TextEditingController();
  String _query = '';

  // Supabase Realtime presence channel for online dots
  late final RealtimeChannel _presenceChannel;
  final Set<String> _onlineIds = {};

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
    _subscribePresence();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.toLowerCase().trim());
    });
  }

  void _subscribePresence() {
    final me = Supabase.instance.client.auth.currentUser?.id ?? '';
    _presenceChannel = Supabase.instance.client
        .channel('online-users')
        .onPresenceSync((_) {
          // presenceState() in realtime_client 2.7.x returns a typed object;
          // cast to Map<String, dynamic> to avoid version-specific type errors.
          final raw = _presenceChannel.presenceState() as Map<String, dynamic>;
          if (!mounted) return;
          setState(() {
            _onlineIds.clear();
            raw.forEach((_, value) {
              final list = value as List<dynamic>;
              for (final item in list) {
                // ignore: avoid_dynamic_calls
                final payload = (item as dynamic).payload as Map<String, dynamic>?;
                final uid = payload?['user_id'] as String?;
                if (uid != null && uid != me) _onlineIds.add(uid);
              }
            });
          });
        })
        .subscribe((status, _) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await _presenceChannel.track({'user_id': me});
          }
        });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _presenceChannel.unsubscribe();
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  String _peerId(Map<String, dynamic> c) {
    final me = Supabase.instance.client.auth.currentUser?.id ?? '';
    return c['requester_id'] == me
        ? c['receiver_id'] as String
        : c['requester_id'] as String;
  }

  Map<String, dynamic>? _peerProfile(Map<String, dynamic> c) {
    final me = Supabase.instance.client.auth.currentUser?.id ?? '';
    return (c['requester_id'] == me ? c['receiver'] : c['requester'])
        as Map<String, dynamic>?;
  }

  String _peerName(Map<String, dynamic> c) {
    return (_peerProfile(c)?['name'] as String? ?? 'Unknown').trim();
  }

  Color _avatarColor(String peerId) {
    final palette = [
      const Color(0xFF58DAD0),
      const Color(0xFFFF8A65),
      const Color(0xFFBA68C8),
      const Color(0xFF4DD0E1),
      const Color(0xFF81C784),
      const Color(0xFFFFB74D),
    ];
    return palette[peerId.hashCode.abs() % palette.length];
  }

  String _timestamp(Map<String, dynamic> c) {
    final raw = c['updated_at'] as String?;
    if (raw == null) return '';
    try {
      final dt  = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        final h = dt.hour > 12
            ? dt.hour - 12
            : dt.hour == 0 ? 12 : dt.hour;
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m ${dt.hour >= 12 ? 'PM' : 'AM'}';
      }
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset    = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final previewsAsync = ref.watch(chatPreviewsProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Header ────────────────────────────────────────────────────
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
                      GestureDetector(
                        onTap: () => ref.refresh(chatPreviewsProvider),
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

              // ── Search bar ────────────────────────────────────────────────
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
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(color: _text, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search conversations...',
                              hintStyle: const TextStyle(
                                  color: Color(0xFF3D5C58), fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                              suffixIcon: _query.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () => _searchCtrl.clear(),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFF3D5C58),
                                        size: 16,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Body ──────────────────────────────────────────────────────
              previewsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1EC9B8),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Could not load chats',
                      style: TextStyle(color: _faint, fontSize: 14),
                    ),
                  ),
                ),
                data: (raw) {
                  final chats = _query.isEmpty
                      ? raw
                      : raw.where((c) {
                          final name = _peerName(c).toLowerCase();
                          return name.contains(_query);
                        }).toList();

                  final activeChats = chats
                      .where((c) => _onlineIds.contains(_peerId(c)))
                      .toList();

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Active now strip
                      if (activeChats.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                          child: Text(
                            'ACTIVE NOW',
                            style: TextStyle(
                              color: Color(0xFF3D5C58),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: activeChats.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, i) {
                              final c    = activeChats[i];
                              final pid  = _peerId(c);
                              final name = _peerName(c);
                              final col  = _avatarColor(pid);
                              return GestureDetector(
                                onTap: () => context.go(
                                  '/chat/$pid',
                                  extra: {
                                    'peerName':  name,
                                    'tripLabel': 'Trip',
                                  },
                                ),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        _AvatarCircle(
                                          initial: name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : '?',
                                          color: col,
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
                                                color:
                                                    const Color(0xFF081314),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      name.split(' ').first,
                                      style: const TextStyle(
                                        color: _muted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      // Recent label
                      if (chats.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                          child: Text(
                            'RECENT',
                            style: TextStyle(
                              color: Color(0xFF3D5C58),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),

                      // Chat rows
                      ...chats.map((c) {
                        final pid      = _peerId(c);
                        final name     = _peerName(c);
                        final col      = _avatarColor(pid);
                        final isOnline = _onlineIds.contains(pid);
                        final ts       = _timestamp(c);

                        return _ChatRow(
                          connectionId: c['id'] as String,
                          peerId:    pid,
                          peerName:  name,
                          color:     col,
                          isOnline:  isOnline,
                          timestamp: ts,
                          onTap: () => context.go(
                            '/chat/$pid',
                            extra: {
                              'peerName':  name,
                              'tripLabel': 'Trip',
                            },
                          ),
                        );
                      }),

                      // Empty state
                      if (chats.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Color(0xFF3D5C58),
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _query.isNotEmpty
                                    ? 'No results for "$_query"'
                                    : 'No conversations yet',
                                style: const TextStyle(
                                  color: Color(0xFF3D5C58),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 100 + bottomInset),
                    ]),
                  );
                },
              ),
            ],
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

// ── Chat row ──────────────────────────────────────────────────────────────────

class _ChatRow extends ConsumerWidget {
  final String connectionId;
  final String peerId;
  final String peerName;
  final Color  color;
  final bool   isOnline;
  final String timestamp;
  final VoidCallback onTap;

  const _ChatRow({
    required this.connectionId,
    required this.peerId,
    required this.peerName,
    required this.color,
    required this.isOnline,
    required this.timestamp,
    required this.onTap,
  });

  static const _text    = Color(0xFFEDF7F4);
  static const _muted   = Color(0xFF8AADA8);
  static const _faint   = Color(0xFF3D5C58);
  static const _teal    = Color(0xFF1EC9B8);
  static const _teal2   = Color(0xFF58DAD0);
  static const _surface = Color(0xFF0C1D1F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesStreamProvider(connectionId));
    final me = Supabase.instance.client.auth.currentUser?.id ?? '';

    final lastMsg = messagesAsync.whenOrNull(
      data: (msgs) => msgs.isNotEmpty ? msgs.last : null,
    );

    final unread = messagesAsync.whenOrNull(
          data: (msgs) => msgs
              .where((m) => m.senderId != me && m.readAt == null)
              .length,
        ) ?? 0;

    final hasUnread = unread > 0;
    final initial   = peerName.isNotEmpty ? peerName[0].toUpperCase() : '?';

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
            Stack(
              children: [
                _AvatarCircle(initial: initial, color: color, size: 50),
                if (isOnline)
                  Positioned(
                    bottom: 2, right: 2,
                    child: Container(
                      width: 11, height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF081314), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          peerName,
                          style: TextStyle(
                            color: _text,
                            fontSize: 15,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        timestamp,
                        style: TextStyle(
                          color: hasUnread ? _teal2 : _faint,
                          fontSize: 11,
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg?.content ?? 'Say hello 👋',
                          style: TextStyle(
                            color: hasUnread ? _muted : _faint,
                            fontSize: 13,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF58DAD0),
                                Color(0xFF1EC9B8),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
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

// ── Shared avatar widget ──────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  final String initial;
  final Color  color;
  final double size;

  const _AvatarCircle({
    required this.initial,
    required this.color,
    required this.size,
  });

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
