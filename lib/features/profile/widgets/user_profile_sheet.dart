// lib/features/profile/widgets/user_profile_sheet.dart

import 'package:flutter/material.dart';

// ─── Lightweight profile model (self-contained, no extra files needed) ────────

class _TravelLogEntry {
  final String emoji;
  final String destination;
  final String companions;
  const _TravelLogEntry({required this.emoji, required this.destination, required this.companions});
}

class _TravelReview {
  final String initial;
  final String name;
  final String tripLabel;
  final String text;
  const _TravelReview({required this.initial, required this.name, required this.tripLabel, required this.text});
}

class UserProfileData {
  final String name;
  final int age;
  final String basedIn;
  final String avatarInitial;
  final Color avatarColor;
  final double rating;
  final int tripCount;
  final int buddyCount;
  final String bio;
  final List<String> vibes;
  final String activeTripName;
  final String activeTripDates;
  final String activeTripLooking;
  final List<_TravelLogEntry> travelLog;
  final List<_TravelReview> reviews;

  const UserProfileData({
    required this.name,
    required this.age,
    required this.basedIn,
    required this.avatarInitial,
    required this.avatarColor,
    required this.rating,
    required this.tripCount,
    required this.buddyCount,
    required this.bio,
    required this.vibes,
    required this.activeTripName,
    required this.activeTripDates,
    required this.activeTripLooking,
    required this.travelLog,
    required this.reviews,
  });
}

// ─── Mock profiles keyed by first name (lowercase) ───────────────────────────

final _mockProfiles = <String, UserProfileData>{
  'meera': UserProfileData(
    name: 'Meera', age: 24, basedIn: 'Pune',
    avatarInitial: 'M', avatarColor: const Color(0xFF58DAD0),
    rating: 4.9, tripCount: 8, buddyCount: 12,
    bio: 'Adventure seeker by default. Mountains, high altitudes, and terrible wifi — that\'s the dream. Always looking for a solid trek partner.',
    vibes: ['🏔 Adventure', '🎒 Backpacker', '🌄 Sunrise Chaser'],
    activeTripName: 'Spiti Valley Crew',
    activeTripDates: 'May 10–18',
    activeTripLooking: 'Looking for 1–2',
    travelLog: [
      _TravelLogEntry(emoji: '🏔', destination: 'Leh Ladakh', companions: 'with Arjun +2'),
      _TravelLogEntry(emoji: '🌴', destination: 'Andaman', companions: 'Solo'),
      _TravelLogEntry(emoji: '🏛', destination: 'Hampi', companions: 'with Sara'),
      _TravelLogEntry(emoji: '❄️', destination: 'Kasol', companions: 'with 3 others'),
    ],
    reviews: [
      _TravelReview(initial: 'A', name: 'Arjun K.', tripLabel: 'Leh • Aug 2025', text: 'Meera is an incredible travel buddy. Planned every detail, kept spirits high even at 17,000 ft. Would trek again in a heartbeat!'),
      _TravelReview(initial: 'S', name: 'Sara M.', tripLabel: 'Hampi • Feb 2025', text: 'Super organised and so much fun. Never a dull moment. Highly recommend travelling with Meera.'),
    ],
  ),
  'anika': UserProfileData(
    name: 'Anika', age: 26, basedIn: 'Delhi',
    avatarInitial: 'A', avatarColor: const Color(0xFFB57BFF),
    rating: 4.7, tripCount: 6, buddyCount: 9,
    bio: 'History nerd who turned it into travel goals. Heritage sites, local bazaars, and street food — that\'s my kind of trip.',
    vibes: ['🏛 Culture', '📸 Photographer', '☕ Cafe Hopper'],
    activeTripName: 'Jaipur Heritage Crew',
    activeTripDates: 'May 14–17',
    activeTripLooking: 'Looking for 1',
    travelLog: [
      _TravelLogEntry(emoji: '🏯', destination: 'Jaisalmer', companions: 'Solo'),
      _TravelLogEntry(emoji: '🕌', destination: 'Agra', companions: 'with Neha'),
      _TravelLogEntry(emoji: '🌊', destination: 'Pondicherry', companions: 'with 2 others'),
    ],
    reviews: [
      _TravelReview(initial: 'N', name: 'Neha R.', tripLabel: 'Agra • Jan 2025', text: 'Anika knows every hidden gem in every city. Best travel guide I\'ve ever had. Genuinely fun to be around.'),
    ],
  ),
  'priya': UserProfileData(
    name: 'Priya', age: 25, basedIn: 'Bangalore',
    avatarInitial: 'P', avatarColor: const Color(0xFF58DAD0),
    rating: 4.8, tripCount: 5, buddyCount: 7,
    bio: 'Beaches, hammocks and zero agenda. I travel slow. If you\'re rushing, we\'re not a match. Chill-first always.',
    vibes: ['🌊 Beach Bum', '🧘 Mindful', '🌅 Sunset Hunter'],
    activeTripName: 'Kerala Backwaters Crew',
    activeTripDates: 'May 20–25',
    activeTripLooking: 'Looking for 2',
    travelLog: [
      _TravelLogEntry(emoji: '🌴', destination: 'Goa', companions: 'with Dev +1'),
      _TravelLogEntry(emoji: '🏝', destination: 'Varkala', companions: 'Solo'),
      _TravelLogEntry(emoji: '🌿', destination: 'Coorg', companions: 'with friends'),
    ],
    reviews: [
      _TravelReview(initial: 'D', name: 'Dev S.', tripLabel: 'Goa • Mar 2025', text: 'Calmest travel buddy ever. No drama, good vibes only. The kind of person that makes the trip feel effortless.'),
    ],
  ),
  'meera r.': UserProfileData(
    name: 'Meera', age: 24, basedIn: 'Pune',
    avatarInitial: 'M', avatarColor: const Color(0xFF58DAD0),
    rating: 4.9, tripCount: 8, buddyCount: 12,
    bio: 'Adventure seeker by default. Mountains, high altitudes, and terrible wifi — that\'s the dream. Always looking for a solid trek partner.',
    vibes: ['🏔 Adventure', '🎒 Backpacker', '🌄 Sunrise Chaser'],
    activeTripName: 'Spiti Valley Crew',
    activeTripDates: 'May 10–18',
    activeTripLooking: 'Looking for 1–2',
    travelLog: [
      _TravelLogEntry(emoji: '🏔', destination: 'Leh Ladakh', companions: 'with Arjun +2'),
      _TravelLogEntry(emoji: '🌴', destination: 'Andaman', companions: 'Solo'),
      _TravelLogEntry(emoji: '🏛', destination: 'Hampi', companions: 'with Sara'),
      _TravelLogEntry(emoji: '❄️', destination: 'Kasol', companions: 'with 3 others'),
    ],
    reviews: [
      _TravelReview(initial: 'A', name: 'Arjun K.', tripLabel: 'Leh • Aug 2025', text: 'Meera is an incredible travel buddy. Planned every detail, kept spirits high even at 17,000 ft. Would trek again in a heartbeat!'),
      _TravelReview(initial: 'S', name: 'Sara M.', tripLabel: 'Hampi • Feb 2025', text: 'Super organised and so much fun. Never a dull moment. Highly recommend travelling with Meera.'),
    ],
  ),
  'anika s.': UserProfileData(
    name: 'Anika', age: 26, basedIn: 'Delhi',
    avatarInitial: 'A', avatarColor: const Color(0xFFB57BFF),
    rating: 4.7, tripCount: 6, buddyCount: 9,
    bio: 'History nerd who turned it into travel goals. Heritage sites, local bazaars, and street food — that\'s my kind of trip.',
    vibes: ['🏛 Culture', '📸 Photographer', '☕ Cafe Hopper'],
    activeTripName: 'Jaipur Heritage Crew',
    activeTripDates: 'May 14–17',
    activeTripLooking: 'Looking for 1',
    travelLog: [
      _TravelLogEntry(emoji: '🏯', destination: 'Jaisalmer', companions: 'Solo'),
      _TravelLogEntry(emoji: '🕌', destination: 'Agra', companions: 'with Neha'),
      _TravelLogEntry(emoji: '🌊', destination: 'Pondicherry', companions: 'with 2 others'),
    ],
    reviews: [
      _TravelReview(initial: 'N', name: 'Neha R.', tripLabel: 'Agra • Jan 2025', text: 'Anika knows every hidden gem in every city. Best travel guide I\'ve ever had. Genuinely fun to be around.'),
    ],
  ),
  'priya k.': UserProfileData(
    name: 'Priya', age: 25, basedIn: 'Bangalore',
    avatarInitial: 'P', avatarColor: const Color(0xFF58DAD0),
    rating: 4.8, tripCount: 5, buddyCount: 7,
    bio: 'Beaches, hammocks and zero agenda. I travel slow. If you\'re rushing, we\'re not a match. Chill-first always.',
    vibes: ['🌊 Beach Bum', '🧘 Mindful', '🌅 Sunset Hunter'],
    activeTripName: 'Kerala Backwaters Crew',
    activeTripDates: 'May 20–25',
    activeTripLooking: 'Looking for 2',
    travelLog: [
      _TravelLogEntry(emoji: '🌴', destination: 'Goa', companions: 'with Dev +1'),
      _TravelLogEntry(emoji: '🏝', destination: 'Varkala', companions: 'Solo'),
      _TravelLogEntry(emoji: '🌿', destination: 'Coorg', companions: 'with friends'),
    ],
    reviews: [
      _TravelReview(initial: 'D', name: 'Dev S.', tripLabel: 'Goa • Mar 2025', text: 'Calmest travel buddy ever. No drama, good vibes only. The kind of person that makes the trip feel effortless.'),
    ],
  ),
};

UserProfileData _fallbackProfile(String name) => UserProfileData(
  name: name, age: 24, basedIn: 'India',
  avatarInitial: name.isNotEmpty ? name[0].toUpperCase() : '?',
  avatarColor: const Color(0xFF58DAD0),
  rating: 4.8, tripCount: 6, buddyCount: 10,
  bio: 'Travel enthusiast always looking for the next adventure and great company.',
  vibes: ['🌍 Explorer', '🎒 Backpacker'],
  activeTripName: 'Upcoming Trip',
  activeTripDates: 'Coming soon',
  activeTripLooking: 'Looking for buddies',
  travelLog: [
    _TravelLogEntry(emoji: '✈️', destination: 'Past trip', companions: 'Solo'),
  ],
  reviews: [],
);

UserProfileData profileDataFromName(String rawName) {
  final key = rawName.toLowerCase().trim();
  return _mockProfiles[key] ??
      _mockProfiles[key.split(' ').first] ??
      _fallbackProfile(rawName.split(' ').first);
}

// ─── The Sheet ────────────────────────────────────────────────────────────────

class UserProfileSheet extends StatefulWidget {
  final UserProfileData profile;
  const UserProfileSheet({super.key, required this.profile});

  /// Call this from any tap handler: UserProfileSheet.show(context, name: match.name)
  static void show(BuildContext context, {required String name}) {
    final profile = profileDataFromName(name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.65),
      builder: (_) => UserProfileSheet(profile: profile),
    );
  }

  @override
  State<UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends State<UserProfileSheet> {
  bool _showRequestForm = false;
  final _msgCtrl = TextEditingController();

  static const _bg      = Color(0xFF081314);
  static const _surface = Color(0xFF0C1D1F);
  static const _teal    = Color(0xFF1EC9B8);
  static const _teal2   = Color(0xFF58DAD0);
  static const _gold    = Color(0xFFF7B84E);
  static const _text    = Color(0xFFEDF7F4);
  static const _muted   = Color(0xFFA8C4BF);
  static const _faint   = Color(0xFF3D5C58);

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final sh = MediaQuery.of(context).size.height;
    final bi = MediaQuery.of(context).padding.bottom;

    return Container(
      height: sh * 0.92,
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // ── Scrollable body ───────────────────────────────────────────────
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 130 + bi),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Hero ─────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: p.avatarColor.withOpacity(.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: p.avatarColor.withOpacity(.40), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            p.avatarInitial,
                            style: TextStyle(
                              color: p.avatarColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name + info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${p.name}, ${p.age}',
                                    style: const TextStyle(
                                      color: _text, fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _gold.withOpacity(.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('⭐', style: TextStyle(fontSize: 11)),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${p.rating}',
                                        style: const TextStyle(
                                          color: _gold, fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '📍 Based in ${p.basedIn}',
                              style: const TextStyle(color: _muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── Stats ─────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _StatBox(value: '${p.tripCount}', label: 'Trips'),
                      const SizedBox(width: 10),
                      _StatBox(value: '${p.rating}', label: 'Rating'),
                      const SizedBox(width: 10),
                      _StatBox(value: '${p.buddyCount}', label: 'Buddies'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // ── About ─────────────────────────────────────────────────────
                _SectionHeader(title: 'About Me'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.bio,
                        style: const TextStyle(
                          color: _muted, fontSize: 13, height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: p.vibes
                            .map((v) => _VibeChip(label: v))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                // ── Active Trip ───────────────────────────────────────────────
                _SectionHeader(
                  title: 'Active Trip',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _teal.withOpacity(.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Broadcasting',
                      style: TextStyle(
                        color: _teal2, fontSize: 10, fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _teal.withOpacity(.15)),
                    ),
                    child: Row(
                      children: [
                        const Text('✈️', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.activeTripName,
                                style: const TextStyle(
                                  color: _text, fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${p.activeTripDates} · ${p.activeTripLooking}',
                                style: const TextStyle(color: _muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Travel Log ────────────────────────────────────────────────
                _SectionHeader(
                  title: 'Travel Log',
                  trailing: const Text(
                    'See All',
                    style: TextStyle(
                      color: _teal2, fontSize: 12, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: p.travelLog.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final e = p.travelLog[i];
                      return Container(
                        width: 100,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(e.emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 6),
                            Text(
                              e.destination,
                              style: const TextStyle(
                                color: _text, fontSize: 12, fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              e.companions,
                              style: const TextStyle(color: _faint, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ── Reviews ───────────────────────────────────────────────────
                if (p.reviews.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Recent Reviews',
                    trailing: Text(
                      'View ${p.reviews.length}',
                      style: const TextStyle(
                        color: _teal2, fontSize: 12, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: p.reviews.map((r) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(.06)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32, height: 32,
                                      decoration: BoxDecoration(
                                        color: _teal2.withOpacity(.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          r.initial,
                                          style: const TextStyle(
                                            color: _teal2, fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.name,
                                          style: const TextStyle(
                                            color: _text, fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          r.tripLabel,
                                          style: const TextStyle(
                                            color: _faint, fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '"${r.text}"',
                                  style: const TextStyle(
                                    color: _muted, fontSize: 12, height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── Fixed bottom CTA ──────────────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomCta(
              profile: p,
              showForm: _showRequestForm,
              msgCtrl: _msgCtrl,
              onAskToJoin: () => setState(() => _showRequestForm = true),
              onSend: () => Navigator.of(context).pop(),
              onDismiss: () => setState(() => _showRequestForm = false),
              bottomInset: bi,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom CTA ───────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  final UserProfileData profile;
  final bool showForm;
  final TextEditingController msgCtrl;
  final VoidCallback onAskToJoin;
  final VoidCallback onSend;
  final VoidCallback onDismiss;
  final double bottomInset;

  const _BottomCta({
    required this.profile,
    required this.showForm,
    required this.msgCtrl,
    required this.onAskToJoin,
    required this.onSend,
    required this.onDismiss,
    required this.bottomInset,
  });

  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _faint = Color(0xFF3D5C58);
  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF081314),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(.06))),
      ),
      child: showForm
          ? Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: _muted, fontSize: 13),
                    children: [
                      const TextSpan(text: 'Asking to join '),
                      TextSpan(
                        text: profile.activeTripName,
                        style: const TextStyle(
                          color: _teal2, fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: '. Introduce yourself to ${profile.name}!'),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(Icons.close_rounded, color: _faint, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C1D1F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(.07)),
            ),
            child: TextField(
              controller: msgCtrl,
              maxLines: 3,
              style: const TextStyle(color: _text, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Your message...',
                hintStyle: TextStyle(color: _faint, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSend,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withOpacity(.25),
                    blurRadius: 12, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Send Request',
                  style: TextStyle(
                    color: Color(0xFF041818),
                    fontSize: 15, fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Messaging unlocks if ${profile.name} accepts',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _faint, fontSize: 12),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onAskToJoin,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF58DAD0), Color(0xFF1EC9B8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withOpacity(.30),
                    blurRadius: 18, offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Ask to Join Trip',
                  style: TextStyle(
                    color: Color(0xFF041818),
                    fontSize: 16, fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFEDF7F4),
                fontSize: 15, fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1D1F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.06)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFEDF7F4),
                fontSize: 18, fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF3D5C58), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _VibeChip extends StatelessWidget {
  final String label;
  const _VibeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1D1F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFA8C4BF), fontSize: 12, fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}