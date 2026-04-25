// lib/features/notifications/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notifications_provider.dart';
import '../models/notification_model.dart';
import '../../profile/widgets/user_profile_sheet.dart';
import '../../connections/providers/connections_provider.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────

const _kBg    = Color(0xFF070E0F);
const _kS1    = Color(0xFF0D1819);
const _kTeal  = Color(0xFF1EC9B8);
const _kTeal2 = Color(0xFF58DAD0);
const _kGold  = Color(0xFFF7B84E);
const _kText  = Color(0xFFEDF7F4);
const _kMuted = Color(0xFFA8C4BF);
const _kFaint = Color(0xFF6A8882);

// ─── Notif types ─────────────────────────────────────────────────────────────

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final notifsAsync = ref.watch(notificationsStreamProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 16),
            decoration: BoxDecoration(
              color: _kBg,
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(.05))),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: _kText, size: 18),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text('Notifications', style: TextStyle(
                    color: _kText, fontSize: 18, fontWeight: FontWeight.w700,
                  )),
                ),
                if (unread > 0)
                  GestureDetector(
                    onTap: () => ref.read(markAllReadProvider.future),
                    child: const Text('Mark all read', style: TextStyle(
                      color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w700,
                    )),
                  ),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: notifsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: _kTeal2, strokeWidth: 2),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e', style: const TextStyle(color: _kMuted)),
              ),
              data: (notifs) {
                if (notifs.isEmpty) return _EmptyState();
                final today = notifs.where((n) =>
                DateTime.now().difference(n.createdAt).inHours < 24).toList();
                final earlier = notifs.where((n) =>
                DateTime.now().difference(n.createdAt).inHours >= 24).toList();
                return ListView(
                  padding: EdgeInsets.only(bottom: 24 + bottom),
                  children: [
                    if (today.isNotEmpty) ...[
                      _SectionLabel('Today', today.where((n) => !n.isRead).length),
                      ...today.map((n) => _NotifTile(
                        notif: n,
                        onAction: () => _onAction(n),
                        onDismiss: () => ref.read(markReadProvider(n.id).future),
                      )),
                    ],
                    if (earlier.isNotEmpty) ...[
                      _SectionLabel('Earlier', 0),
                      ...earlier.map((n) => _NotifTile(
                        notif: n,
                        onAction: () => _onAction(n),
                        onDismiss: () => ref.read(markReadProvider(n.id).future),
                      )),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onAction(NotificationModel n) {
    // Mark read
    ref.read(markReadProvider(n.id).future);

    switch (n.type) {
      case 'trip_request':
        final connId = n.data['connection_id'] as String?;
        if (connId != null) _showTripRequestSheet(n, connId);
        break;
      case 'match_alert':
        UserProfileSheet.show(context, name: n.title.split(' — ').last.split(' ').first);
        break;
      default:
        break;
    }
  }

  void _showTripRequestSheet(NotificationModel n, String connectionId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TripRequestSheet(
        notif: n,
        connectionId: connectionId,
        onAccept: () async {
          await ref.read(acceptRequestProvider(connectionId).future);
          if (mounted) Navigator.of(context).pop();
        },
        onDecline: () async {
          await ref.read(declineRequestProvider(connectionId).future);
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final int unread;
  const _SectionLabel(this.label, this.unread);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(label.toUpperCase(), style: const TextStyle(
            color: _kFaint, fontSize: 10, fontWeight: FontWeight.w800,
            letterSpacing: .08,
          )),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('$unread new', style: const TextStyle(
                color: _kTeal2, fontSize: 10, fontWeight: FontWeight.w800,
              )),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onAction;
  const _NotifTile({required this.notif, required this.onAction});

  IconData get _typeIcon {
    switch (notif.type) {
      case _NType.tripRequest: return Icons.flight_takeoff_rounded;
      case _NType.matchAlert:  return Icons.favorite_rounded;
      case _NType.accepted:    return Icons.check_circle_rounded;
      case _NType.review:      return Icons.star_rounded;
      case _NType.system:      return Icons.shield_rounded;
    }
  }

  Color get _typeColor {
    switch (notif.type) {
      case _NType.tripRequest: return _kTeal;
      case _NType.matchAlert:  return const Color(0xFFFF6B9D);
      case _NType.accepted:    return _kTeal2;
      case _NType.review:      return _kGold;
      case _NType.system:      return _kGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAction,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.unread
              ? _kTeal.withOpacity(.05)
              : Colors.white.withOpacity(.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notif.unread
                ? _kTeal.withOpacity(.12)
                : Colors.white.withOpacity(.04),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar or type icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                notif.avatarInitial != null
                    ? Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: notif.avatarColor!.withOpacity(.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(notif.avatarInitial!, style: TextStyle(
                      color: notif.avatarColor,
                      fontSize: 18, fontWeight: FontWeight.w800,
                    )),
                  ),
                )
                    : Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: _kGold.withOpacity(.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_rounded,
                        color: _kGold, size: 20),
                  ),
                ),
                // Type badge
                Positioned(
                  bottom: -4, right: -4,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: _kBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: _typeColor.withOpacity(.30)),
                    ),
                    child: Center(
                      child: Icon(_typeIcon, color: _typeColor, size: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notif.title, style: TextStyle(
                          color: _kText,
                          fontSize: 13, fontWeight: FontWeight.w700,
                          height: 1.3,
                        )),
                      ),
                      const SizedBox(width: 8),
                      if (notif.unread)
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                            color: _kTeal2, shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif.body, style: const TextStyle(
                    color: _kMuted, fontSize: 12, height: 1.4,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(notif.time, style: const TextStyle(
                        color: _kFaint, fontSize: 11,
                      )),
                      if (notif.actionLabel != null) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _typeColor.withOpacity(.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _typeColor.withOpacity(.22),
                            ),
                          ),
                          child: Text(notif.actionLabel!, style: TextStyle(
                            color: _typeColor,
                            fontSize: 11, fontWeight: FontWeight.w800,
                          )),
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

// ─── Trip request bottom sheet ────────────────────────────────────────────────

class _TripRequestSheet extends StatelessWidget {
  final _Notif notif;
  const _TripRequestSheet({required this.notif});

  @override
  Widget build(BuildContext context) {
    final bi = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bi),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1819),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // Requester avatar + name
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: notif.avatarColor!.withOpacity(.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(notif.avatarInitial!, style: TextStyle(
                    color: notif.avatarColor,
                    fontSize: 22, fontWeight: FontWeight.w800,
                  )),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title.replaceAll('Trip Request from ', ''),
                    style: const TextStyle(
                      color: _kText, fontSize: 17, fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('wants to join your trip', style: TextStyle(
                    color: _kFaint, fontSize: 12,
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Their message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(.06)),
            ),
            child: Text(
              '"${notif.body}"',
              style: const TextStyle(
                color: _kText, fontSize: 13, height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(.08)),
                    ),
                    child: const Center(
                      child: Text('Decline', style: TextStyle(
                        color: _kMuted, fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _kTeal2,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(
                        color: _kTeal.withOpacity(.25),
                        blurRadius: 16, offset: const Offset(0, 6),
                      )],
                    ),
                    child: const Center(
                      child: Text('Accept & Open Chat', style: TextStyle(
                        color: Color(0xFF041818), fontSize: 14,
                        fontWeight: FontWeight.w800,
                      )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Icon(Icons.notifications_none_rounded,
              color: _kFaint.withOpacity(.40), size: 56),
          const SizedBox(height: 16),
          const Text('All caught up', style: TextStyle(
            color: _kText, fontSize: 18, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 8),
          const Text(
            'Trip requests, match alerts, and reviews will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kFaint, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}