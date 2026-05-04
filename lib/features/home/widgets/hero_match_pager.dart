// lib/features/home/widgets/hero_match_pager.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/home_mock_data.dart';
import '../providers/home_provider.dart';
import 'hero_match_card.dart';

class HeroMatchPager extends ConsumerWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final double height;
  final ValueChanged<HomeMatch>? onCardTap;

  const HeroMatchPager({
    super.key,
    required this.controller,
    required this.onPageChanged,
    required this.height,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(homeSearchQueryProvider);
    final rankedAsync = ref.watch(aiRankedTravelersProvider(searchQuery));

    return rankedAsync.when(
      loading: () => _ShimmerHero(height: height),
      error:   (_, __) => _EmptyHero(height: height),
      data: (result) {
        final profiles = result.topMatches;
        if (profiles.isEmpty) return _EmptyHero(height: height);

        final matches = profiles.map((p) => HomeMatch.fromTrip(
          tripId:      p.id,
          creatorName: p.name ?? 'Traveler',
          creatorAge:  p.age ?? 0,
          destination: searchQuery.isNotEmpty ? searchQuery : (p.baseCity ?? 'Exploring'),
          dates:       '',
          avatarUrl:   p.avatarUrl,
          vibe:        p.vibes.isNotEmpty ? p.vibes.first : null,
          rating:      p.rating,
          buddyCount:  p.buddyCount,
        )).toList();

        return PageView.builder(
          controller: controller,
          itemCount:  matches.length,
          onPageChanged: onPageChanged,
          itemBuilder: (_, index) {
            final match = matches[index];
            return GestureDetector(
              onTap: () => onCardTap?.call(match),
              child: HeroMatchCard(match: match, height: height),
            );
          },
        );
      },
    );
  }
}

class _ShimmerHero extends StatelessWidget {
  final double height;
  const _ShimmerHero({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: const Color(0xFF0D1819),
      child: const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF1EC9B8), strokeWidth: 2),
      ),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  final double height;
  const _EmptyHero({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: const Color(0xFF0D1819),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\u2708\uFE0F', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text(
              'No travelers found yet.\nBe the first to set your vibe!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6A8882), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
