import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TravelersGridPage extends StatefulWidget {
  final String destination;
  const TravelersGridPage({super.key, required this.destination});

  @override
  State<TravelersGridPage> createState() => _TravelersGridPageState();
}

class _TravelersGridPageState extends State<TravelersGridPage> {
  int _activeChip = 0;

  static const bg = Color(0xFF070E0F);
  static const text = Color(0xFFEDF7F4);

  final List<String> _chips = [
    'All matches',
    'Next 7 days',
    'Women only',
    'Under ₹15k',
    'Budget',
  ];

  final List<_TravelerData> _travelers = const [
    _TravelerData(name: 'Meera',  age: 24, city: 'Pune',      vibe: '🏔 Adventure', score: 97, scoreColor: 'gold', variant: 1),
    _TravelerData(name: 'Kabir',  age: 26, city: 'Mumbai',    vibe: '🎉 Festival',  score: 94, scoreColor: 'teal', variant: 2),
    _TravelerData(name: 'Anika',  age: 23, city: 'Delhi',     vibe: '☕ Chill',     score: 91, scoreColor: 'teal', variant: 3),
    _TravelerData(name: 'Dev',    age: 25, city: 'Bangalore', vibe: '🥾 Trekking', score: 89, scoreColor: 'gold', variant: 4),
    _TravelerData(name: 'Priya',  age: 22, city: 'Chennai',   vibe: '🌊 Beach',    score: 86, scoreColor: 'teal', variant: 1),
    _TravelerData(name: 'Rohan',  age: 27, city: 'Hyderabad', vibe: '🎸 Party',    score: 83, scoreColor: 'gold', variant: 2),
    _TravelerData(name: 'Sara',   age: 24, city: 'Jaipur',    vibe: '🏛 Culture',  score: 81, scoreColor: 'teal', variant: 3),
    _TravelerData(name: 'Arjun',  age: 28, city: 'Kolkata',   vibe: '📸 Photo',    score: 78, scoreColor: 'gold', variant: 4),
  ];

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
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.7, -1),
            radius: 1.2,
            colors: [Color(0x281EC9B8), Colors.transparent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topInset + 10),

            // ── Header row ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(.06)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: text,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${widget.destination} Travelers',
                      style: const TextStyle(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.03,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1EC9B8).withOpacity(.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF1EC9B8).withOpacity(.22)),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF58DAD0),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Filter chips ─────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = i == _activeChip;
                  return GestureDetector(
                    onTap: () => setState(() => _activeChip = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? text
                            : Colors.white.withOpacity(.04),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: active
                              ? Colors.transparent
                              : Colors.white.withOpacity(.08),
                        ),
                      ),
                      child: Text(
                        _chips[i],
                        style: TextStyle(
                          color: active
                              ? const Color(0xFF041818)
                              : text,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // ── 2-column grid ────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding:
                EdgeInsets.fromLTRB(16, 0, 16, 20 + bottomInset),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: _travelers.length,
                itemBuilder: (_, i) =>
                    _TravelerCardWidget(data: _travelers[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data model ─────────────────────────────────────────────────────────────

class _TravelerData {
  final String name;
  final int age;
  final String city;
  final String vibe;
  final int score;
  final String scoreColor;
  final int variant;

  const _TravelerData({
    required this.name,
    required this.age,
    required this.city,
    required this.vibe,
    required this.score,
    required this.scoreColor,
    required this.variant,
  });
}

// ─── Grid card widget ────────────────────────────────────────────────────────

class _TravelerCardWidget extends StatelessWidget {
  final _TravelerData data;
  const _TravelerCardWidget({required this.data});

  static const text = Color(0xFFEDF7F4);
  static const teal2 = Color(0xFF58DAD0);
  static const gold = Color(0xFFF7B84E);

  static const List<List<Color>> _gradients = [
    [Color(0xFF1E4044), Color(0xFF112425)],
    [Color(0xFF1A342C), Color(0xFF112425)],
    [Color(0xFF36261A), Color(0xFF112425)],
    [Color(0xFF301E28), Color(0xFF112425)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[(data.variant - 1) % 4];
    final scoreColor = data.scoreColor == 'teal' ? teal2 : gold;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              border: Border.all(color: Colors.white.withOpacity(.05)),
            ),
          ),

          // Bottom fade overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(.82),
                ],
                stops: const [0.38, 1.0],
              ),
            ),
          ),

          // Match score pill (top right)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xB20A1213),
                borderRadius: BorderRadius.circular(999),
                border:
                Border.all(color: Colors.white.withOpacity(.10)),
              ),
              child: Text(
                '${data.score}%',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          // Name, city, vibe (bottom)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        color: text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Verified badge
                    Container(
                      width: 13,
                      height: 13,
                      decoration: const BoxDecoration(
                        color: Color(0xFF58DAD0),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '✓',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.age} · ${data.city}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.70),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.vibe,
                    style: const TextStyle(
                      color: text,
                      fontSize: 9,
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