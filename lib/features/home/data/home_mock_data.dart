// lib/features/home/data/home_mock_data.dart
//
// Static mock classes kept for widget compatibility.
// All actual data now comes from Supabase via providers.
// HomeMockData.trays is kept as fallback UI skeletons only.

import 'package:flutter/material.dart';

// class HomeMatch {
//   final String id;
//   final String name;
//   final int age;
//   final String route;
//   final String tripDate;
//   final String imageUrl;
//   final String vibeTag;
//   final List<String> pills;
//   final String destination;
//
//   const HomeMatch({
//     required this.id,
//     required this.name,
//     required this.age,
//     required this.route,
//     required this.tripDate,
//     required this.imageUrl,
//     required this.vibeTag,
//     required this.pills,
//     required this.destination,
//   });
// }

class HomeTrayData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? badge;

  const HomeTrayData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.badge,
  });
}

// TravelerPreview still used by TravelerRail widget shape
class TravelerPreview {
  final String id;
  final String name;
  final String destination;
  final String score;
  final String? avatarUrl;
  final List<Color> gradient;

  const TravelerPreview({
    required this.id,
    required this.name,
    required this.destination,
    required this.score,
    this.avatarUrl,
    required this.gradient,
  });
}

// Helper: build a HomeMatch from a TripModel + ProfileModel
// Used by home_screen to convert live data into the existing card widget shape
class HomeMatch {
  // ... (already defined above — this is a static factory helper)
  static HomeMatch fromTrip({
    required String tripId,
    required String creatorName,
    required int creatorAge,
    required String destination,
    required String dates,
    required String? avatarUrl,
    required String? vibe,
    required double rating,
    required double trustScore,
  }) {
    return HomeMatch(
      id: tripId,
      name: creatorName,
      age: creatorAge,
      route: '— → $destination',
      tripDate: dates,
      imageUrl: avatarUrl ?? '',
      vibeTag: vibe ?? '✈️ Traveler',
      destination: destination,
      pills: [
        '${(trustScore * 100).round()}% trust',
        dates,
        if (rating > 0) '★ $rating',
        'Verified ✓',
      ],
    );
  }
}