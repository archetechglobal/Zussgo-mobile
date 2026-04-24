// lib/features/profile/screens/user_profile_screen.dart
//
// Pixel-perfect Flutter match of zussgo-profile-and-connection.html
//
// Layout (Phone 1):
//   ┌─ 380px hero photo ──────────────────────────┐
//   │  [← back]                    [⭐ 4.9 rating] │
//   │  (gradient overlay bottom)                   │
//   └──────────────────────────────────────────────┘
//   Name, Age  ·  📍 Based in City
//   Stats row (Trips / Rating / Buddies)
//   About Me + vibe chips
//   Active Trip  [Broadcasting]
//   Travel Log (horizontal photo cards)
//   Recent Reviews
//   ── sticky bottom ──
//   [ Ask to Join Trip ]
//   🔒 Messaging unlocks if X accepts
//
// Phone 2 (sheet): Request to Join slides up from bottom

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class _TLog {
  final String title, sub, imgUrl;
  const _TLog(this.title, this.sub, this.imgUrl);
}

class _Rev {
  final String initial, name, tripDate, body;
  const _Rev(this.initial, this.name, this.tripDate, this.body);
}

class _Prof {
  final String name, city, bio, tripName, tripDates, tripLooking;
  final String heroUrl, tripImgUrl;
  final int age, trips, buddies;
  final double rating;
  final List<String> vibes;
  final List<_TLog> log;
  final List<_Rev> reviews;
  const _Prof({
    required this.name, required this.age, required this.city,
    required this.rating, required this.trips, required this.buddies,
    required this.bio, required this.vibes,
    required this.tripName, required this.tripDates, required this.tripLooking,
    required this.heroUrl, required this.tripImgUrl,
    required this.log, required this.reviews,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock database — Unsplash photos match original design
// ─────────────────────────────────────────────────────────────────────────────

const _kDB = <String, _Prof>{
  'meera': _Prof(
    name: 'Meera', age: 24, city: 'Pune',
    rating: 4.9, trips: 8, buddies: 12,
    bio: "Adventure seeker by default. Mountains, high altitudes, and terrible wifi — that's the dream. Always looking for a solid trek partner.",
    vibes: ['🏔 Adventure', '🎒 Backpacker', '🌄 Sunrise Chaser'],
    tripName: 'Spiti Valley Crew', tripDates: 'May 10–18', tripLooking: 'Looking for 1–2',
    heroUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=800&auto=format&fit=crop',
    tripImgUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=200&auto=format&fit=crop',
    log: [
      _TLog('Leh Ladakh',  'with Arjun +2', 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=300&auto=format&fit=crop'),
      _TLog('Andaman',     'Solo',           'https://images.unsplash.com/photo-1589394815804-964ed0be2eb5?q=80&w=300&auto=format&fit=crop'),
      _TLog('Hampi',       'with Sara',      'https://images.unsplash.com/photo-1575994532673-49ee0a376e2f?q=80&w=300&auto=format&fit=crop'),
      _TLog('Kasol',       'with 3 others',  'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?q=80&w=300&auto=format&fit=crop'),
    ],
    reviews: [
      _Rev('A', 'Arjun K.', 'Leh · Aug 2025',
          'Travelled with Meera to Ladakh. Great navigator, always finds the best food spots. 10/10 travel buddy.'),
      _Rev('S', 'Sara M.', 'Hampi · Dec 2025',
          'Meera is incredibly well-organised and calm under pressure. Would definitely travel with her again!'),
    ],
  ),
  'kabir': _Prof(
    name: 'Kabir', age: 26, city: 'Mumbai',
    rating: 4.7, trips: 10, buddies: 15,
    bio: "I'm usually the one planning nightlife, beach days, and last-minute food runs. Big on energy, good playlists, and fun people.",
    vibes: ['🎉 Festival', '🌊 Beach Days', '🎵 Playlists'],
    tripName: 'Goa Beach Crew', tripDates: 'May 12–15', tripLooking: 'Looking for 1–2',
    heroUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=800&auto=format&fit=crop',
    tripImgUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?q=80&w=200&auto=format&fit=crop',
    log: [
      _TLog('Goa',    'with Dev +3',   'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?q=80&w=300&auto=format&fit=crop'),
      _TLog('Phuket', 'Solo',          'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?q=80&w=300&auto=format&fit=crop'),
      _TLog('Pondy',  'with Aryan',    'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?q=80&w=300&auto=format&fit=crop'),
      _TLog('Hampi',  'with 2 others', 'https://images.unsplash.com/photo-1575994532673-49ee0a376e2f?q=80&w=300&auto=format&fit=crop'),
    ],
    reviews: [
      _Rev('D', 'Dev S.', 'Goa · Nov 2025',
          'Kabir brings the fun. Super social, knows the scene, and somehow still keeps the trip moving smoothly.'),
    ],
  ),
  'anika': _Prof(
    name: 'Anika', age: 23, city: 'Delhi',
    rating: 4.8, trips: 6, buddies: 10,
    bio: 'Into coffee, old cities, slow mornings, and documenting little details. I like thoughtful itineraries with room for spontaneous detours.',
    vibes: ['☕ Chill', '📸 Photo Walks', '🏛 Culture'],
    tripName: 'Jaipur Escape', tripDates: 'May 14–17', tripLooking: 'Looking for 1',
    heroUrl: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?q=80&w=800&auto=format&fit=crop',
    tripImgUrl: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?q=80&w=200&auto=format&fit=crop',
    log: [
      _TLog('Jaipur',       'with Naina',    'https://images.unsplash.com/photo-1477587458883-47145ed94245?q=80&w=300&auto=format&fit=crop'),
      _TLog('Agra',         'Solo',          'https://images.unsplash.com/photo-1564507592333-c60657eea523?q=80&w=300&auto=format&fit=crop'),
      _TLog('Udaipur',      'with friends',  'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?q=80&w=300&auto=format&fit=crop'),
      _TLog('Pondicherry',  'Solo',          'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?q=80&w=300&auto=format&fit=crop'),
    ],
    reviews: [
      _Rev('N', 'Naina P.', 'Jaipur · Dec 2025',
          'Anika is super easy to travel with. Great taste, calm energy, and always finds the most aesthetic spots.'),
    ],
  ),
  'dev': _Prof(
    name: 'Dev', age: 25, city: 'Bangalore',
    rating: 4.6, trips: 7, buddies: 11,
    bio: "Trek routes, cabins, cold weather, and early starts. I'm into trips that feel earned and end with stories.",
    vibes: ['🥾 Trekking', '🏕 Outdoors', '❄️ Mountains'],
    tripName: 'Coorg Trails', tripDates: 'Jun 2–5', tripLooking: 'Looking for 1–2',
    heroUrl: 'https://images.unsplash.com/photo-1530543787849-128d94430c6b?q=80&w=800&auto=format&fit=crop',
    tripImgUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=200&auto=format&fit=crop',
    log: [
      _TLog('Coorg',  'with Kabir',    'https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=300&auto=format&fit=crop'),
      _TLog('Kasol',  'Solo',          'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?q=80&w=300&auto=format&fit=crop'),
      _TLog('Munnar', 'with 2 others', 'https://images.unsplash.com/photo-1580677125853-d8bc5b63a2ef?q=80&w=300&auto=format&fit=crop'),
      _TLog('Ooty',   'Solo',          'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?q=80&w=300&auto=format&fit=crop'),
    ],
    reviews: [
      _Rev('K', 'Kabir M.', 'Coorg · Aug 2025',
          'Very dependable on the road. If Dev is leading the trip, you know it will be smooth and scenic.'),
    ],
  ),
  'priya': _Prof(
    name: 'Priya', age: 22, city: 'Chennai',
    rating: 4.8, trips: 5, buddies: 8,
    bio: "I like coastal places, easy conversations, and plans that don't feel too rigid. Looking for genuine, safe, fun travel company.",
    vibes: ['🌊 Beach', '🪷 Slow Travel', '☀️ Golden Hour'],
    tripName: 'Kerala Coast Crew', tripDates: 'May 22–26', tripLooking: 'Looking for 1–2',
    heroUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=800&auto=format&fit=crop',
    tripImgUrl: 'https://images.unsplash.com/photo-1511988617509-a57c8a288659?q=80&w=200&auto=format&fit=crop',
    log: [
      _TLog('Kerala',   'with Neha',   'https://images.unsplash.com/photo-1511988617509-a57c8a288659?q=80&w=300&auto=format&fit=crop'),
      _TLog('Goa',      'Solo',        'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?q=80&w=300&auto=format&fit=crop'),
      _TLog('Pondy',    'with friends','https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?q=80&w=300&auto=format&fit=crop'),
      _TLog('Andaman',  'Solo',        'https://images.unsplash.com/photo-1589394815804-964ed0be2eb5?q=80&w=300&auto=format&fit=crop'),
    ],
    reviews: [
      _Rev('N', 'Neha T.', 'Kerala · Jan 2026',
          'Priya is relaxed, thoughtful, and very easy to travel with. Great conversations and zero unnecessary chaos.'),
    ],
  ),
  'rohan': _Prof(
    name: 'Rohan', age: 27, city: 'Hyderabad',
    rating: 4.5, trips: 9, buddies: 13,
    bio: "Party first, plan second. Always up for spontaneous plans, good music, and new faces.",
    vibes: ['🎸 Party', '🌃 Nightlife', '🤝 Social'],
    tripName: 'Goa NYE Crew', tripDates: 'Dec 28–Jan 2', tripLooking: 'Looking for 2–3',
    heroUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=800&auto=format&fit=crop',
    tripImgUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?q=80&w=200&auto=format&fit=crop',
    log: [
      _TLog('Goa',       'with 4 others', 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?q=80&w=300&auto=format&fit=crop'),
      _TLog('Bangkok',   'Solo',          'https://images.unsplash.com/photo-1508009603885-50cf7c579365?q=80&w=300&auto=format&fit=crop'),
      _TLog('Mumbai',    'with Kabir',    'https://images.unsplash.com/photo-1595658658481-d53d3f999875?q=80&w=300&auto=format&fit=crop'),
      _TLog('Hyderabad', 'Local host',    'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?q=80&w=300&auto=format&fit=crop'),
    ],
    reviews: [
      _Rev('K', 'Kabir M.', 'Goa · Mar 2025',
          "Rohan is the life of any trip. If you want energy and good vibes, he's your guy."),
    ],
  ),
};

_Prof _resolve(String n) =>
    _kDB[n.toLowerCase().trim().split(' ').first] ?? _kDB['meera']!;

// ─────────────────────────────────────────────────────────────────────────────
// Screen — slides up full-screen from bottom
// ─────────────────────────────────────────────────────────────────────────────

class UserProfileScreen extends StatefulWidget {
  final String name;
  const UserProfileScreen({super.key, required this.name});

  /// Call from anywhere — slides up full-screen
  static Future<void> show(BuildContext ctx, {required String name}) =>
      Navigator.of(ctx).push(PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => UserProfileScreen(name: name),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInCubic,
          )),
          child: child,
        ),
      ));

  @override
  State<UserProfileScreen> createState() => _S();
}

class _S extends State<UserProfileScreen> {
  bool _sheet = false;
  final _ctrl = TextEditingController();

  // exact tokens from CSS variables
  static const _bg    = Color(0xFF0B1516);
  static const _s1    = Color(0xFF0D1819);
  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);
  static const _faint = Color(0xFF6A8882);
  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);
  static const _gold  = Color(0xFFF7B84E);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final p   = _resolve(widget.name);
    final bot = MediaQuery.of(ctx).padding.bottom;
    final top = MediaQuery.of(ctx).padding.top;

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Scrollable content ───────────────────────────────────────
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [

                // ── HERO PHOTO (380px) — matches .hero CSS exactly ────
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 380,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // cover photo
                        Image.network(
                          p.heroUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF1A3A35),
                            child: const Center(
                              child: Icon(Icons.person_rounded,
                                  size: 80, color: Color(0xFF58DAD0)),
                            ),
                          ),
                        ),

                        // gradient overlay — transparent → #0b1516 (matches CSS)
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 0.38, 1.0],
                              colors: [
                                Color(0x4D000000), // rgba(0,0,0,.3)
                                Colors.transparent,
                                Color(0xFF0B1516),
                              ],
                            ),
                          ),
                        ),

                        // top actions — back + rating (matches .top-actions)
                        Positioned(
                          top: top + 14,
                          left: 20, right: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ← back
                              GestureDetector(
                                onTap: () => Navigator.of(ctx).pop(),
                                child: Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(.40),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(.10)),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: _text, size: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // rating badge bottom-right (matches .hero-rating)
                        Positioned(
                          bottom: 24, right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.60),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(.10)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: _gold, size: 16),
                                const SizedBox(width: 5),
                                Text(
                                  '${p.rating}',
                                  style: const TextStyle(
                                    color: _text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── NAME + CITY (.p-info — margin-top: -20px overlap) ──
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // name row
                          Row(
                            children: [
                              Text(
                                '${p.name}, ${p.age}',
                                style: const TextStyle(
                                  color: _text,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Lexend',
                                  letterSpacing: -0.03,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // city
                          Row(children: [
                            const Text('📍', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              'Based in ${p.city}',
                              style: const TextStyle(
                                  color: _muted, fontSize: 14),
                            ),
                          ]),
                          const SizedBox(height: 20),

                          // ── STATS ROW ──────────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(.06)),
                            ),
                            child: IntrinsicHeight(
                              child: Row(children: [
                                _StatCell('${p.trips}',   'TRIPS'),
                                VerticalDivider(width: 1,
                                    color: Colors.white.withOpacity(.06)),
                                _StatCell('${p.rating}',  'RATING'),
                                VerticalDivider(width: 1,
                                    color: Colors.white.withOpacity(.06)),
                                _StatCell('${p.buddies}', 'BUDDIES'),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── ABOUT ME ───────────────────────────────
                          _SecTitle('About Me'),
                          const SizedBox(height: 12),
                          Text(p.bio,
                              style: const TextStyle(
                                  color: _muted, fontSize: 14, height: 1.6)),
                          const SizedBox(height: 16),
                          Wrap(spacing: 8, runSpacing: 8,
                              children: p.vibes
                                  .map((v) => _VibeTag(v))
                                  .toList()),
                          const SizedBox(height: 32),

                          // ── ACTIVE TRIP ────────────────────────────
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              _SecTitle('Active Trip'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _teal.withOpacity(.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Broadcasting',
                                    style: TextStyle(
                                      color: _teal2, fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.04,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // mini trip card (matches .mini-trip)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _teal.withOpacity(.08),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _teal.withOpacity(.20)),
                            ),
                            child: Row(children: [
                              // trip thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  p.tripImgUrl,
                                  width: 48, height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 48, height: 48,
                                    color: _teal.withOpacity(.15),
                                    child: const Icon(Icons.flight_rounded,
                                        color: _teal2, size: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text('BROADCASTING',
                                        style: TextStyle(
                                          color: _teal2, fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.05,
                                        )),
                                    const SizedBox(height: 4),
                                    Text(p.tripName,
                                        style: const TextStyle(
                                          color: _text, fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Lexend',
                                        )),
                                    const SizedBox(height: 3),
                                    Text(
                                        '${p.tripDates} · ${p.tripLooking}',
                                        style: const TextStyle(
                                            color: _muted, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 32),

                          // ── TRAVEL LOG HEADER ──────────────────────
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              _SecTitle('Travel Log'),
                              const Text('See All',
                                  style: TextStyle(
                                      color: _teal2, fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── TRAVEL LOG — horizontal photo cards ──────────────
                // (.trip-card-h: 130px wide × 150px tall, photo bg)
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: SizedBox(
                      height: 150,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: p.log.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            _TLogCard(item: p.log[i]),
                      ),
                    ),
                  ),
                ),

                // ── RECENT REVIEWS ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              _SecTitle('Recent Reviews'),
                              Text('View ${p.reviews.length}',
                                  style: const TextStyle(
                                      color: _teal2, fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...p.reviews.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ReviewCard(r: r),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),

                // bottom padding for action bar
                SliverToBoxAdapter(
                    child: SizedBox(height: 100 + bot)),
              ],
            ),
          ),

          // ── STICKY ACTION BAR (bottom) ───────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _ActionBar(
              name: p.name,
              bot: bot,
              onTap: () => setState(() => _sheet = true),
            ),
          ),

          // ── REQUEST SHEET (Phone 2) ──────────────────────────────────
          if (_sheet)
            _RequestSheet(
              p: p, ctrl: _ctrl,
              onClose: () => setState(() => _sheet = false),
              onSend: () => Navigator.of(ctx).pop(),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String v, l;
  const _StatCell(this.v, this.l);
  static const _text  = Color(0xFFEDF7F4);
  static const _faint = Color(0xFF6A8882);
  @override
  Widget build(_) => Expanded(child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(children: [
      Text(v, style: const TextStyle(
          color: _text, fontSize: 18, fontWeight: FontWeight.w700,
          fontFamily: 'Lexend')),
      const SizedBox(height: 3),
      Text(l, style: const TextStyle(
          color: _faint, fontSize: 10, fontWeight: FontWeight.w800,
          letterSpacing: 0.05)),
    ]),
  ));
}

class _SecTitle extends StatelessWidget {
  final String t;
  const _SecTitle(this.t);
  @override
  Widget build(_) => Text(t, style: const TextStyle(
      color: Color(0xFFEDF7F4), fontSize: 16,
      fontWeight: FontWeight.w700, fontFamily: 'Lexend',
      letterSpacing: -0.02));
}

class _VibeTag extends StatelessWidget {
  final String label;
  const _VibeTag(this.label);
  @override
  Widget build(_) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0x1A1EC9B8),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0x331EC9B8)),
    ),
    child: Text(label, style: const TextStyle(
        color: Color(0xFF58DAD0), fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

// Travel log card — photo background with gradient overlay (matches .trip-card-h)
class _TLogCard extends StatelessWidget {
  final _TLog item;
  const _TLogCard({required this.item});
  @override
  Widget build(_) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      width: 130, height: 150,
      child: Stack(fit: StackFit.expand, children: [
        // photo bg
        Image.network(
          item.imgUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFF1A3535)),
        ),
        // gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.38, 1.0],
              colors: [Colors.transparent, Color(0xCC000000)],
            ),
          ),
        ),
        // text bottom
        Positioned(
          left: 12, right: 12, bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lexend',
                  )),
              const SizedBox(height: 2),
              Text(item.sub,
                  style: TextStyle(
                      color: Colors.white.withOpacity(.70),
                      fontSize: 11)),
            ],
          ),
        ),
      ]),
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  final _Rev r;
  const _ReviewCard({required this.r});
  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);
  static const _faint = Color(0xFF6A8882);
  static const _teal2 = Color(0xFF58DAD0);
  static const _gold  = Color(0xFFF7B84E);
  @override
  Widget build(_) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.03),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(.06)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: const Color(0x261EC9B8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(r.initial, style: const TextStyle(
                  color: _teal2, fontSize: 14, fontWeight: FontWeight.w700,
                  fontFamily: 'Lexend'))),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name, style: const TextStyle(
                  color: _text, fontSize: 14, fontWeight: FontWeight.w600,
                  fontFamily: 'Lexend')),
              Text(r.tripDate, style: const TextStyle(
                  color: _muted, fontSize: 11)),
            ]),
          ]),
          Row(children: List.generate(5, (_) =>
          const Icon(Icons.star_rounded, color: _gold, size: 13))),
        ],
      ),
      const SizedBox(height: 12),
      Text('"${r.body}"',
          style: const TextStyle(color: _text, fontSize: 13, height: 1.5)),
    ]),
  );
}

class _ActionBar extends StatelessWidget {
  final String name;
  final double bot;
  final VoidCallback onTap;
  const _ActionBar({required this.name, required this.bot, required this.onTap});
  static const _bg    = Color(0xFF0B1516);
  static const _faint = Color(0xFF6A8882);
  @override
  Widget build(_) => Container(
    padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bot),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [_bg.withOpacity(.0), _bg],
        stops: const [0.0, 0.35],
      ),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      // white button (matches .btn-request exactly)
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity, height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFEDF7F4), // --text (white-ish)
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: Colors.white.withOpacity(.10),
                blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: const Center(child: Text('Ask to Join Trip',
              style: TextStyle(
                  color: Colors.black, fontSize: 16,
                  fontWeight: FontWeight.w800, fontFamily: 'Lexend'))),
        ),
      ),
      const SizedBox(height: 12),
      // lock text
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.lock_outline_rounded, color: _faint, size: 12),
        const SizedBox(width: 5),
        Text('Messaging unlocks if $name accepts',
            style: const TextStyle(
                color: _faint, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ]),
  );
}

class _RequestSheet extends StatelessWidget {
  final _Prof p;
  final TextEditingController ctrl;
  final VoidCallback onClose, onSend;
  const _RequestSheet({
    required this.p, required this.ctrl,
    required this.onClose, required this.onSend});
  static const _text  = Color(0xFFEDF7F4);
  static const _muted = Color(0xFFA8C4BF);
  static const _faint = Color(0xFF6A8882);
  static const _teal  = Color(0xFF1EC9B8);
  @override
  Widget build(BuildContext ctx) {
    final bot = MediaQuery.of(ctx).padding.bottom;
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withOpacity(.60),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // absorb taps inside sheet
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24, 12, 24, 40 + bot),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFF111D1E), Color(0xFF08100F)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border(top: BorderSide(color: Color(0x331EC9B8))),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // handle
                  Container(width: 40, height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.20),
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),

                  const Text('Request to Join',
                      style: TextStyle(color: _text, fontSize: 20,
                          fontWeight: FontWeight.w700, fontFamily: 'Lexend')),
                  const SizedBox(height: 8),

                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                          color: _muted, fontSize: 13, height: 1.4),
                      children: [
                        const TextSpan(text: 'You are asking to join '),
                        TextSpan(text: p.tripName,
                            style: const TextStyle(
                                color: _text, fontWeight: FontWeight.w600)),
                        TextSpan(
                            text: '. Introduce yourself to ${p.name}!'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // message input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(.08)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('YOUR MESSAGE', style: TextStyle(
                              color: _faint, fontSize: 11, fontWeight: FontWeight.w800,
                              letterSpacing: 0.05)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: ctrl, maxLines: 3,
                            style: const TextStyle(
                                color: _text, fontSize: 14, height: 1.5),
                            decoration: InputDecoration(
                                border: InputBorder.none, isCollapsed: true,
                                hintText: 'Hey ${p.name}! Your ${p.tripName} sounds exactly like what I\'m looking for...',
                                hintStyle: TextStyle(
                                    color: _faint.withOpacity(.6),
                                    fontSize: 13, height: 1.5)),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 20),

                  // send btn
                  GestureDetector(
                    onTap: onSend,
                    child: Container(
                      width: double.infinity, height: 56,
                      decoration: BoxDecoration(
                        color: _teal,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                            color: _teal.withOpacity(.25),
                            blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: const Center(child: Text('Send Request',
                          style: TextStyle(
                              color: Colors.black, fontSize: 16,
                              fontWeight: FontWeight.w800, fontFamily: 'Lexend'))),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}