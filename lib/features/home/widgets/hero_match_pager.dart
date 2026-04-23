import 'package:flutter/material.dart';
import '../data/home_mock_data.dart';
import 'hero_match_card.dart';

class HeroMatchPager extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final double height;

  const HeroMatchPager({
    super.key,
    required this.controller,
    required this.onPageChanged,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: HomeMockData.matches.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, index) {
        return HeroMatchCard(
          match: HomeMockData.matches[index],
          height: height,
        );
      },
    );
  }
}