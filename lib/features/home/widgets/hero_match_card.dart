import 'package:flutter/material.dart';
import '../data/home_mock_data.dart';

class HeroMatchCard extends StatelessWidget {
  final HomeMatch match;
  final double height;

  const HeroMatchCard({
    super.key,
    required this.match,
    required this.height,
  });

  static const bg = Color(0xFF081314);
  static const surface2 = Color(0xFF0B1516);
  static const text = Color(0xFFEAF7F3);
  static const teal = Color(0xFF20C9B8);
  static const teal2 = Color(0xFF58DAD0);
  static const gold = Color(0xFFF7B84E);
  static const rose = Color(0xFFFF7E8E);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        margin: const EdgeInsets.only(left: 0, right: 0, top: 0),
        decoration: BoxDecoration(
          color: surface2,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(34),
            bottomRight: Radius.circular(34),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.30),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(34),
            bottomRight: Radius.circular(34),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                match.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1D4044),
                          Color(0xFF163338),
                          Color(0xFF0E2427),
                          Color(0xFF091718),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(.05),
                      Colors.black.withOpacity(.02),
                      Colors.transparent,
                      const Color(0x990B1516),
                      const Color(0xE60B1516),
                      const Color(0xFF0B1516),
                    ],
                    stops: const [0.0, 0.22, 0.46, 0.72, 0.88, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GlassTag(label: match.vibeTag),
                    const SizedBox(height: 10),
                    Text(
                      match.name,
                      style: const TextStyle(
                        color: text,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${match.age} · ${match.route}, ${match.tripDate}',
                      style: const TextStyle(
                        color: Color(0xB8EAF7F3),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: match.pills.map((pill) {
                        final isGold = pill.contains('% match');
                        final isTeal =
                            pill.contains('Same') || pill.contains('Verified');
                        return _MetaPill(
                          label: pill,
                          color: isGold
                              ? gold
                              : isTeal
                              ? teal2
                              : text,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [teal2, teal],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: teal.withOpacity(.24),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Connect with ${match.name.split(' ').first} →',
                                style: const TextStyle(
                                  color: bg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const _IconButtonBox(
                          icon: Icons.close_rounded,
                          color: HeroMatchCard.rose,
                        ),
                        const SizedBox(width: 10),
                        const _IconButtonBox(
                          icon: Icons.favorite_border_rounded,
                          color: HeroMatchCard.text,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTag extends StatelessWidget {
  final String label;

  const _GlassTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.32),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFEAF7F3),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MetaPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IconButtonBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconButtonBox({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color == HeroMatchCard.rose
            ? color.withOpacity(.08)
            : Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}