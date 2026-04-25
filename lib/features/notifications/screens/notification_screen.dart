// lib/features/notifications/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../profile/widgets/user_profile_sheet.dart';

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

enum _NType { tripRequest, matchAlert, accepted, review, system }

class _Notif {
  final _NType type;
  final String title;
  final String body;
  final String time;
  final String? avatarInitial;
  final Color? avatarColor;
  final bool unread;
  final String? actionLabel;

  const _Notif({
    required this.type, required this.title,
    required this.body, required this.time,
    this.avatarInitial, this.avatarColor,
    this.unread = false, this.actionLabel,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _notifs = [
  _Notif(
    type: _NType.tripRequest,
    title: 'Trip Request from Meera',
    body: 'Hey! Your Spiti Valley trip sounds exactly like what I\'m looking for. Can I join?',
    time: '2m ago',
    avatarInitial: 'M', avatarColor: const Color(0xFF58DAD0),
    unread: true, actionLabel: 'Respond',
  ),
  _Notif(
    type: _NType.matchAlert,
    title: '97% Match — Kabir is going to Goa',
    body: 'Kabir D. from Mumbai is heading to Goa May 12–15. Your vibe match is 97%.',
    time: '18m ago',
    avatarInitial: 'K', avatarColor: const Color(0xFFF7B84E),
    unread: true, actionLabel: 'View Profile',
  ),
  _Notif(
    type: _NType.accepted,
    title: 'Anika accepted your request!',
    body: 'You can now message Anika. Your chat for the Jaipur Heritage trip is open.',
    time: '1h ago',
    avatarInitial: 'A', avatarColor: const Color(0xFFB57BFF),
    unread: true, actionLabel: 'Open Chat',
  ),
  _Notif(
    type: _NType.review,
    title: 'Arjun left you a review',
    body: 'Arjun K. rated your trip to Leh ⭐⭐⭐⭐⭐ and left a public review.',
    time: '3h ago',
    avatarInitial: 'A', avatarColor: const Color(0xFFF7B84E),
    unread: false, actionLabel: 'See Review',
  ),
  _Notif(
    type: _NType.tripRequest,
    title: 'Trip Request from Dev',
    body: 'Dev S. wants to join your Kerala Backwaters trip. May 20–25.',
    time: '5h ago',
    avatarInitial: 'D', avatarColor: const Color(0xFF1EC9B8),
    unread: false, actionLabel: 'Respond',
  ),
  _Notif(
    type: _NType.matchAlert,
    title: '91% Match — Priya is going to Kerala',
    body: 'Priya K. from Bangalore matches your travel style. She\'s going May 20.',
    time: 'Yesterday',
    avatarInitial: 'P', avatarColor: const Color(0xFF9FD9BE),
    unread: false, actionLabel: 'View Profile',
  ),
  _Notif(
    type: _NType.system,
    title: 'Complete your Trust Score',
    body: 'Link a Govt. ID to unlock Priority Matching and reach more travelers.',
    time: 'Yesterday',
    avatarInitial: null, avatarColor: null,
    unread: false, actionLabel: 'Boost Score',
  ),
  _Notif(
    type: _NType.accepted,
    title: 'Sara accepted your connection!',
    body: 'You and Sara are now connected. Start planning your Udaipur trip.',
    time: '2 days ago',
    avatarInitial: 'S', avatarColor: const Color(0xFF1EC9B8),
    unread: false, actionLabel: 'Open Chat',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<int> _dismissed = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  int get _unreadCount =>
      _notifs.where((n) => n.unread).length -
          _dismissed.where((i) => _notifs[i].unread).length;

  List<_Notif> get _today =>
      _notifs.asMap().entries
          .where((e) => !_dismissed.contains(e.key) &&
          (e.value.time.contains('m ago') || e.value.time.contains('h ago')))
          .map((e) => e.value).toList();

  List<_Notif> get _earlier =>
      _notifs.asMap().entries
          .where((e) => !_dismissed.contains(e.key) &&
          (e.value.time.contains('day') || e.value.time == 'Yesterday'))
          .map((e) => e.value).toList();

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 16),
            decoration: BoxDecoration(
              color: _kBg,
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(.05)),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _kText, size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text('Notifications', style: TextStyle(
                    color: _kText, fontSize: 18, fontWeight: FontWeight.w700,
                  )),
                ),
                if (_unreadCount > 0)
                  GestureDetector(
                    onTap: () => setState(() {
                      for (int i = 0; i < _notifs.length; i++) {
                        _dismissed.add(i);
                      }
                    }),
                    child: const Text('Mark all read', style: TextStyle(
                      color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w700,
                    )),
                  ),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: 24 + bottom),
              children: [
                if (_today.isNotEmpty) ...[
                  _SectionLabel('Today', _unreadCount),
                  ..._buildGroup(_today),
                ],
                if (_earlier.isNotEmpty) ...[
                  _SectionLabel('Earlier', 0),
                  ..._buildGroup(_earlier),
                ],
                if (_today.isEmpty && _earlier.isEmpty)
                  _EmptyState(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroup(List<_Notif> notifs) {
    return notifs.map((n) {
      final globalIdx = _notifs.indexOf(n);
      return Dismissible(
        key: ValueKey('${n.title}-$globalIdx'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red.withOpacity(.15),
          child: const Icon(Icons.delete_outline_rounded,
              color: Color(0xFFFF4D4D), size: 22),
        ),
        onDismissed: (_) => setState(() => _dismissed.add(globalIdx)),
        child: _NotifTile(
          notif: n,
          onAction: () => _onAction(n),
        ),
      );
    }).toList();
  }

  void _onAction(_Notif n) {
    switch (n.type) {
      case _NType.tripRequest:
        _showTripRequestSheet(n);
        break;
      case _NType.matchAlert:
        UserProfileSheet.show(
          context,
          name: n.avatarInitial ?? 'Traveler',
        );
        break;
      case _NType.accepted:
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  void _showTripRequestSheet(_Notif n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TripRequestSheet(notif: n),
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