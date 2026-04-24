// lib/features/home/widgets/hero_match_pager.dart

import 'package:flutter/material.dart';
import '../data/home_mock_data.dart';
import 'hero_match_card.dart';

class HeroMatchPager extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final double height;
  final ValueChanged<HomeMatch>? onCardTap; // ← NEW

  const HeroMatchPager({
    super.key,
    required this.controller,
    required this.onPageChanged,
    required this.height,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: HomeMockData.matches.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, index) {
        final match = HomeMockData.matches[index];
        return GestureDetector(
          onTap: () => onCardTap?.call(match),
          child: HeroMatchCard(
            match: match,
            height: height,
          ),
        );
      },
    );
  }
}