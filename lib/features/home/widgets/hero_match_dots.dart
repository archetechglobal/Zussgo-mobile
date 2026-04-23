import 'package:flutter/material.dart';

class HeroMatchDots extends StatelessWidget {
  final int currentIndex;
  final int count;

  const HeroMatchDots({
    super.key,
    required this.currentIndex,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 6,
        children: List.generate(
          count,
              (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: index == currentIndex ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: index == currentIndex
                  ? const Color(0xFF58DAD0)
                  : Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}