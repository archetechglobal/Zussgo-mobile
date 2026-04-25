// lib/features/profile/widgets/user_profile_sheet.dart

import 'package:flutter/material.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class TravelLogEntry {
  final String destination;
  final String companions;
  final String imageUrl;
  const TravelLogEntry({
    required this.destination,
    required this.companions,
    required this.imageUrl,
  });
}

class TravelReview {
  final String initial;
  final String name;
  final String tripLabel;
  final String text;
  final double stars;
  const TravelReview({
    required this.initial,
    required this.name,
    required this.tripLabel,
    required this.text,
    this.stars = 5,
  });
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
  final String activeTripImageUrl;
  final List<TravelLogEntry> travelLog;
  final List<TravelReview> reviews;
  final String heroImageUrl;

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
    required this.activeTripImageUrl,
    required this.travelLog,
    required this.reviews,
    required this.heroImageUrl,
  });
}

// ─── Mock profiles ────────────────────────────────────────────────────────────

final _mockProfiles = <String, UserProfileData>{
  'meera': UserProfileData(
    name: 'Meera', age: 24, basedIn: 'Pune',
    avatarInitial: 'M', avatarColor: const Color(0xFF58DAD0),
    rating: 4.9, tripCount: 8, buddyCount: 12,
    heroImageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80',
    bio: 'Adventure seeker by default. Mountains, high altitudes, and terrible wifi — that\'s the dream. Always looking for a solid trek partner.',
    vibes: ['🏔 Adventure', '🎒 Backpacker', '🌄 Sunrise Chaser'],
    activeTripName: 'Spiti Valley Crew',
    activeTripDates: 'May 10–18',
    activeTripLooking: 'Looking for 1–2',
    activeTripImageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=200&q=80',
    travelLog: [
      TravelLogEntry(destination: 'Leh Ladakh', companions: 'with Arjun +2', imageUrl: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Andaman', companions: 'Solo', imageUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Hampi', companions: 'with Sara', imageUrl: 'https://images.unsplash.com/photo-1581793745862-99fde7fa73d2?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Kasol', companions: 'with 3 others', imageUrl: 'https://images.unsplash.com/photo-1623143521360-1e5ce6c9657b?auto=format&fit=crop&w=300&q=80'),
    ],
    reviews: [
      TravelReview(initial: 'A', name: 'Arjun K.', tripLabel: 'Leh · Aug 2025', stars: 5, text: 'Meera is an incredible travel buddy. Planned every detail, kept spirits high even at 17,000 ft. Would trek again in a heartbeat!'),
      TravelReview(initial: 'S', name: 'Sara M.', tripLabel: 'Hampi · Feb 2025', stars: 5, text: 'Super organised and so much fun. Never a dull moment. Highly recommend travelling with Meera.'),
    ],
  ),
  'anika': UserProfileData(
    name: 'Anika', age: 26, basedIn: 'Delhi',
    avatarInitial: 'A', avatarColor: const Color(0xFFB57BFF),
    rating: 4.7, tripCount: 6, buddyCount: 9,
    heroImageUrl: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=900&q=80',
    bio: 'History nerd who turned it into travel goals. Heritage sites, local bazaars, and street food — that\'s my kind of trip.',
    vibes: ['🏛 Culture', '📸 Photographer', '☕ Cafe Hopper'],
    activeTripName: 'Jaipur Heritage Crew',
    activeTripDates: 'May 14–17',
    activeTripLooking: 'Looking for 1',
    activeTripImageUrl: 'https://images.unsplash.com/photo-1477587458883-47145ed31282?auto=format&fit=crop&w=200&q=80',
    travelLog: [
      TravelLogEntry(destination: 'Jaisalmer', companions: 'Solo', imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Agra', companions: 'with Neha', imageUrl: 'https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Pondicherry', companions: 'with 2 others', imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?auto=format&fit=crop&w=300&q=80'),
    ],
    reviews: [
      TravelReview(initial: 'N', name: 'Neha R.', tripLabel: 'Agra · Jan 2025', stars: 5, text: 'Anika knows every hidden gem in every city. Best travel guide I\'ve ever had. Genuinely fun to be around.'),
    ],
  ),
  'priya': UserProfileData(
    name: 'Priya', age: 25, basedIn: 'Bangalore',
    avatarInitial: 'P', avatarColor: const Color(0xFF58DAD0),
    rating: 4.8, tripCount: 5, buddyCount: 7,
    heroImageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80',
    bio: 'Beaches, hammocks and zero agenda. I travel slow. If you\'re rushing, we\'re not a match. Chill-first always.',
    vibes: ['🌊 Beach Bum', '🧘 Mindful', '🌅 Sunset Hunter'],
    activeTripName: 'Kerala Backwaters Crew',
    activeTripDates: 'May 20–25',
    activeTripLooking: 'Looking for 2',
    activeTripImageUrl: 'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?auto=format&fit=crop&w=200&q=80',
    travelLog: [
      TravelLogEntry(destination: 'Goa', companions: 'with Dev +1', imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Varkala', companions: 'Solo', imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Coorg', companions: 'with friends', imageUrl: 'https://images.unsplash.com/photo-1518684079-3c830dcef090?auto=format&fit=crop&w=300&q=80'),
    ],
    reviews: [
      TravelReview(initial: 'D', name: 'Dev S.', tripLabel: 'Goa · Mar 2025', stars: 5, text: 'Calmest travel buddy ever. No drama, good vibes only. The kind of person that makes the trip feel effortless.'),
    ],
  ),
  'kabir': UserProfileData(
    name: 'Kabir', age: 26, basedIn: 'Mumbai',
    avatarInitial: 'K', avatarColor: const Color(0xFF1EC9B8),
    rating: 4.6, tripCount: 7, buddyCount: 11,
    heroImageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=900&q=80',
    bio: 'Festival circuits and last-minute flights. If there\'s a lineup, a crowd, and good energy — I\'m already there.',
    vibes: ['🎉 Festival', '🎸 Live Music', '🌃 Night Owl'],
    activeTripName: 'Goa Beach Crew',
    activeTripDates: 'May 12–15',
    activeTripLooking: 'Looking for 1–2',
    activeTripImageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=200&q=80',
    travelLog: [
      TravelLogEntry(destination: 'Bali', companions: 'with Sarah +2', imageUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Manali', companions: 'with Rahul', imageUrl: 'https://images.unsplash.com/photo-1623143521360-1e5ce6c9657b?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Dubai', companions: 'Solo', imageUrl: 'https://images.unsplash.com/photo-1518684079-3c830dcef090?auto=format&fit=crop&w=300&q=80'),
    ],
    reviews: [
      TravelReview(initial: 'S', name: 'Sarah M.', tripLabel: 'Bali · Oct 2025', stars: 5, text: 'Great navigator, always finds the best food spots. 10/10 travel buddy.'),
    ],
  ),
  'dev': UserProfileData(
    name: 'Dev', age: 25, basedIn: 'Bangalore',
    avatarInitial: 'D', avatarColor: const Color(0xFFF7B84E),
    rating: 4.5, tripCount: 4, buddyCount: 6,
    heroImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=900&q=80',
    bio: 'Trail boots always packed, itinerary always loose. I trek, I eat, I sleep. Repeat.',
    vibes: ['🥾 Trekking', '🏕 Camping', '🌲 Nature'],
    activeTripName: 'Coorg Trek',
    activeTripDates: 'May 18–22',
    activeTripLooking: 'Looking for 1',
    activeTripImageUrl: 'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?auto=format&fit=crop&w=200&q=80',
    travelLog: [
      TravelLogEntry(destination: 'Coorg', companions: 'with Priya', imageUrl: 'https://images.unsplash.com/photo-1518684079-3c830dcef090?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Munnar', companions: 'Solo', imageUrl: 'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?auto=format&fit=crop&w=300&q=80'),
    ],
    reviews: [
      TravelReview(initial: 'P', name: 'Priya K.', tripLabel: 'Coorg · Mar 2025', stars: 5, text: 'Dev knows every trail. Never gets tired, never complains. Perfect trek partner.'),
    ],
  ),
  'sara': UserProfileData(
    name: 'Sara', age: 24, basedIn: 'Jaipur',
    avatarInitial: 'S', avatarColor: const Color(0xFF1EC9B8),
    rating: 4.6, tripCount: 5, buddyCount: 8,
    heroImageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=900&q=80',
    bio: 'Architecture, art, and amazing food. I find the best cafes in every city. Culture-first traveller.',
    vibes: ['🏛 Culture', '📸 Photographer', '🎨 Art'],
    activeTripName: 'Udaipur Weekend',
    activeTripDates: 'May 16–18',
    activeTripLooking: 'Looking for 1',
    activeTripImageUrl: 'https://images.unsplash.com/photo-1477587458883-47145ed31282?auto=format&fit=crop&w=200&q=80',
    travelLog: [
      TravelLogEntry(destination: 'Udaipur', companions: 'Solo', imageUrl: 'https://images.unsplash.com/photo-1477587458883-47145ed31282?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Jodhpur', companions: 'with Anika', imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=300&q=80'),
    ],
    reviews: [],
  ),
  'rohan': UserProfileData(
    name: 'Rohan', age: 27, basedIn: 'Hyderabad',
    avatarInitial: 'R', avatarColor: const Color(0xFFF7B84E),
    rating: 4.3, tripCount: 3, buddyCount: 5,
    heroImageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=900&q=80',
    bio: 'Spontaneous, loud, and always up for the after-party. Party-first, sleep-optional traveller.',
    vibes: ['🎸 Party', '🌃 Night Owl', '🍻 Social'],
    activeTripName: 'Goa Long Weekend',
    activeTripDates: 'May 12–15',
    activeTripLooking: 'Looking for 2',
    activeTripImageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=200&q=80',
    travelLog: [
      TravelLogEntry(destination: 'Goa', companions: 'with friends', imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=300&q=80'),
    ],
    reviews: [],
  ),
  'arjun': UserProfileData(
    name: 'Arjun', age: 28, basedIn: 'Kolkata',
    avatarInitial: 'A', avatarColor: const Color(0xFFF7B84E),
    rating: 4.7, tripCount: 9, buddyCount: 14,
    heroImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=900&q=80',
    bio: 'Everything is a photo opportunity. I carry two cameras and zero plans. Let the city show you what it wants.',
    vibes: ['📸 Photo', '🏙 Urban', '🎨 Street Art'],
    activeTripName: 'Kolkata to Darjeeling',
    activeTripDates: 'May 22–26',
    activeTripLooking: 'Looking for 1',
    activeTripImageUrl: 'https://images.unsplash.com/photo-1623143521360-1e5ce6c9657b?auto=format&fit=crop&w=200&q=80',
    travelLog: [
      TravelLogEntry(destination: 'Darjeeling', companions: 'Solo', imageUrl: 'https://images.unsplash.com/photo-1623143521360-1e5ce6c9657b?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Varanasi', companions: 'with Meera', imageUrl: 'https://images.unsplash.com/photo-1561361058-c24cecae35ca?auto=format&fit=crop&w=300&q=80'),
      TravelLogEntry(destination: 'Leh', companions: 'with 3 others', imageUrl: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=300&q=80'),
    ],
    reviews: [
      TravelReview(initial: 'M', name: 'Meera R.', tripLabel: 'Varanasi · Dec 2025', stars: 5, text: 'Arjun\'s eye for photography made every moment cinematic. Best travel buddy I\'ve had.'),
    ],
  ),
};

UserProfileData _fallbackProfile(String name) => UserProfileData(
  name: name, age: 24, basedIn: 'India',
  avatarInitial: name.isNotEmpty ? name[0].toUpperCase() : '?',
  avatarColor: const Color(0xFF58DAD0),
  rating: 4.8, tripCount: 6, buddyCount: 10,
  heroImageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=900&q=80',
  bio: 'Travel enthusiast always looking for the next adventure and great company.',
  vibes: ['🌍 Explorer', '🎒 Backpacker'],
  activeTripName: 'Upcoming Trip',
  activeTripDates: 'Coming soon',
  activeTripLooking: 'Looking for buddies',
  activeTripImageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=200&q=80',
  travelLog: [
    TravelLogEntry(destination: 'Past trip', companions: 'Solo', imageUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=300&q=80'),
  ],
  reviews: [],
);

UserProfileData profileDataFromName(String rawName) {
  final key = rawName.toLowerCase().trim();
  return _mockProfiles[key] ??
      _mockProfiles[key.split(' ').first] ??
      _fallbackProfile(rawName.split(' ').first);
}

// ─── Colours ──────────────────────────────────────────────────────────────────

const _kBg      = Color(0xFF0B1516);
const _kSurface = Color(0xFF0D1819);
const _kTeal    = Color(0xFF1EC9B8);
const _kTeal2   = Color(0xFF58DAD0);
const _kGold    = Color(0xFFF7B84E);
const _kText    = Color(0xFFEDF7F4);
const _kMuted   = Color(0xFFA8C4BF);
const _kFaint   = Color(0xFF6A8882);

// ─── The Sheet ────────────────────────────────────────────────────────────────

class UserProfileSheet extends StatefulWidget {
  final UserProfileData profile;
  const UserProfileSheet({super.key, required this.profile});

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

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p  = widget.profile;
    final sh = MediaQuery.of(context).size.height;
    final bi = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        height: sh * 0.94,
        color: _kBg,
        child: Stack(
          children: [
            // ── Scrollable body ─────────────────────────────────────────────
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 140 + bi),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 1. Hero photo (380px, full bleed)
                  _ProfileHero(
                    profile: p,
                    onClose: () => Navigator.of(context).pop(),
                  ),

                  // 2. Name + location — overlaps hero bottom by 20px
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name row
                              Row(
                                children: [
                                  Text(
                                    '${p.name}, ${p.age}',
                                    style: const TextStyle(
                                      color: _kText,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _VerifiedBadge(),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Location
                              Text(
                                '📍 Based in ${p.basedIn}',
                                style: const TextStyle(color: _kMuted, fontSize: 14),
                              ),
                              const SizedBox(height: 20),

                              // 3. Stats row
                              _StatsRow(
                                trips: p.tripCount,
                                rating: p.rating,
                                buddies: p.buddyCount,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 4. About Me
                        _SectionTitle(title: 'About Me'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            p.bio,
                            style: const TextStyle(
                              color: _kMuted, fontSize: 14, height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                            spacing: 8, runSpacing: 8,
                            children: p.vibes.map((v) => _VibeChip(label: v)).toList(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 5. Active Trip
                        _SectionTitle(title: 'Active Trip'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _ActiveTripCard(profile: p),
                        ),
                        const SizedBox(height: 32),

                        // 6. Travel Log
                        _SectionTitle(
                          title: 'Travel Log',
                          trailing: const Text(
                            'See All',
                            style: TextStyle(
                              color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: p.travelLog.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, i) => _TravelLogCard(entry: p.travelLog[i]),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 7. Recent Reviews
                        if (p.reviews.isNotEmpty) ...[
                          _SectionTitle(
                            title: 'Recent Reviews',
                            trailing: Text(
                              'View ${p.reviews.length}',
                              style: const TextStyle(
                                color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: p.reviews.map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ReviewCard(review: r),
                              )).toList(),
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Fixed bottom CTA ────────────────────────────────────────────
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
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  final UserProfileData profile;
  final VoidCallback onClose;
  const _ProfileHero({required this.profile, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          Image.network(
            profile.heroImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [profile.avatarColor.withOpacity(.7), _kBg],
                ),
              ),
            ),
          ),

          // Gradient: dark 30% top → transparent 40% → solid bg at 100%
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.30),
                    Colors.transparent,
                    _kBg,
                  ],
                  stops: const [0.0, 0.40, 1.0],
                ),
              ),
            ),
          ),

          // Drag handle
          Positioned(
            top: 10, left: 0, right: 0,
            child: Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.30),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),

          // Back button — top left
          Positioned(
            top: 36, left: 20,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(.10)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _kText, size: 16,
                ),
              ),
            ),
          ),

          // Rating badge — bottom RIGHT (exactly as in design)
          Positioned(
            bottom: 24, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.60),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(.10)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: _kGold, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    '${profile.rating}',
                    style: const TextStyle(
                      color: _kText, fontSize: 14, fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Verified badge ───────────────────────────────────────────────────────────

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: const BoxDecoration(color: _kTeal2, shape: BoxShape.circle),
      child: const Center(
        child: Text('✓', style: TextStyle(
          color: Color(0xFF041818), fontSize: 10, fontWeight: FontWeight.w900,
        )),
      ),
    );
  }
}

// ─── Stats row (single bordered container with internal dividers) ──────────────

class _StatsRow extends StatelessWidget {
  final int trips;
  final double rating;
  final int buddies;
  const _StatsRow({required this.trips, required this.rating, required this.buddies});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _StatCell(value: '$trips', label: 'TRIPS'),
          Container(width: 1, height: 36, color: Colors.white.withOpacity(.06)),
          _StatCell(value: '$rating', label: 'RATING'),
          Container(width: 1, height: 36, color: Colors.white.withOpacity(.06)),
          _StatCell(value: '$buddies', label: 'BUDDIES'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(
            color: _kText, fontSize: 18, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(
            color: _kFaint, fontSize: 10, fontWeight: FontWeight.w800,
            letterSpacing: .05,
          )),
        ],
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(
              color: _kText, fontSize: 16, fontWeight: FontWeight.w700,
            )),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Vibe chip (teal bg + border + text) ─────────────────────────────────────

class _VibeChip extends StatelessWidget {
  final String label;
  const _VibeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _kTeal.withOpacity(.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kTeal.withOpacity(.20)),
      ),
      child: Text(label, style: const TextStyle(
        color: _kTeal2, fontSize: 12, fontWeight: FontWeight.w600,
      )),
    );
  }
}

// ─── Active trip card ─────────────────────────────────────────────────────────

class _ActiveTripCard extends StatelessWidget {
  final UserProfileData profile;
  const _ActiveTripCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_kTeal.withOpacity(.08), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kTeal.withOpacity(.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination photo thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              profile.activeTripImageUrl,
              width: 48, height: 48, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 48, height: 48,
                color: _kTeal.withOpacity(.15),
                child: const Icon(Icons.flight_takeoff_rounded, color: _kTeal2, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BROADCASTING',
                  style: TextStyle(
                    color: _kTeal2, fontSize: 10, fontWeight: FontWeight.w800,
                    letterSpacing: .05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(profile.activeTripName, style: const TextStyle(
                  color: _kText, fontSize: 15, fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 4),
                Text(
                  '${profile.activeTripDates} · ${profile.activeTripLooking}',
                  style: const TextStyle(color: _kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Travel log card (photo card 130×150) ────────────────────────────────────

class _TravelLogCard extends StatelessWidget {
  final TravelLogEntry entry;
  const _TravelLogCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 130, height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              entry.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _kSurface),
            ),
            // Bottom gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(.80)],
                    stops: const [0.40, 1.0],
                  ),
                ),
              ),
            ),
            // Text overlay
            Positioned(
              left: 12, right: 12, bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.destination, style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 2),
                  Text(entry.companions, style: TextStyle(
                    color: Colors.white.withOpacity(.70), fontSize: 11,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Review card (with star rating) ──────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final TravelReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Avatar initial
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _kTeal.withOpacity(.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(review.initial, style: const TextStyle(
                        color: _kTeal2, fontSize: 14, fontWeight: FontWeight.w700,
                      )),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.name, style: const TextStyle(
                        color: _kText, fontSize: 14, fontWeight: FontWeight.w600,
                      )),
                      Text(review.tripLabel, style: const TextStyle(
                        color: _kMuted, fontSize: 11,
                      )),
                    ],
                  ),
                ],
              ),
              // Gold star rating
              Row(
                children: List.generate(review.stars.round(), (_) =>
                const Icon(Icons.star_rounded, color: _kGold, size: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.text, style: const TextStyle(
            color: _kText, fontSize: 13, height: 1.5,
          )),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      decoration: BoxDecoration(
        color: _kBg,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(.06))),
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, _kBg],
          stops: const [0.0, 0.2],
        ),
      ),
      child: showForm
          ? _RequestForm(
        profile: profile,
        msgCtrl: msgCtrl,
        onSend: onSend,
        onDismiss: onDismiss,
      )
          : _JoinCta(profile: profile, onAskToJoin: onAskToJoin),
    );
  }
}

class _JoinCta extends StatelessWidget {
  final UserProfileData profile;
  final VoidCallback onAskToJoin;
  const _JoinCta({required this.profile, required this.onAskToJoin});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // White CTA button (design: var(--text) bg, black text)
        GestureDetector(
          onTap: onAskToJoin,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: _kText,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: Colors.white.withOpacity(.10),
                blurRadius: 24, offset: const Offset(0, 8),
              )],
            ),
            child: const Center(
              child: Text(
                'Ask to Join Trip',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16, fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Lock text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, color: _kFaint, size: 12),
            const SizedBox(width: 4),
            Text(
              'Messaging unlocks if ${profile.name} accepts',
              style: const TextStyle(
                color: _kFaint, fontSize: 11, fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RequestForm extends StatelessWidget {
  final UserProfileData profile;
  final TextEditingController msgCtrl;
  final VoidCallback onSend;
  final VoidCallback onDismiss;
  const _RequestForm({
    required this.profile,
    required this.msgCtrl,
    required this.onSend,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(
          child: Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.20),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Title
        const Center(
          child: Text('Request to Join', style: TextStyle(
            color: _kText, fontSize: 20, fontWeight: FontWeight.w700,
          )),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(color: _kMuted, fontSize: 13, height: 1.4),
              children: [
                const TextSpan(text: 'You are asking to join '),
                TextSpan(
                  text: profile.activeTripName,
                  style: const TextStyle(color: _kText, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: '. Introduce yourself to ${profile.name}!'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Text input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR MESSAGE',
                style: TextStyle(
                  color: _kFaint, fontSize: 10, fontWeight: FontWeight.w800,
                  letterSpacing: .05,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                style: const TextStyle(color: _kText, fontSize: 14, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'Hey ${profile.name}! Your trip sounds exactly like what I\'m looking for...',
                  hintStyle: const TextStyle(color: _kFaint, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Send button (teal, matching design)
        GestureDetector(
          onTap: onSend,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: _kTeal,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: _kTeal.withOpacity(.20),
                blurRadius: 24, offset: const Offset(0, 8),
              )],
            ),
            child: const Center(
              child: Text(
                'Send Request',
                style: TextStyle(
                  color: Color(0xFF041818),
                  fontSize: 16, fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}