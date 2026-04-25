import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeHeader extends StatelessWidget {
  final double topInset;
  const HomeHeader({super.key, required this.topInset});

  static const text = Color(0xFFEAF7F3);
  static const faint = Color(0xFF6A8882);
  static const teal = Color(0xFF20C9B8);
  static const teal2 = Color(0xFF58DAD0);
  static const gold = Color(0xFFF7B84E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topInset + 10, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Good afternoon',
                    style: TextStyle(
                      color: Color(0x99EAF7F3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Hey, Aryan',
                    style: TextStyle(
                      color: text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [teal2, teal, gold],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Color(0xFF041818),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          color: gold,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0B1516),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
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
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xE00D1819),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: teal.withOpacity(.18)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: faint.withOpacity(.95), size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Where are you headed?',
                    style: TextStyle(
                      color: faint,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: teal.withOpacity(.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: teal.withOpacity(.18)),
                  ),
                  child: const Text(
                    '✦ AI Match',
                    style: TextStyle(
                      color: teal2,
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