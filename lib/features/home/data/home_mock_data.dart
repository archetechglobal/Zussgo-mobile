// lib/features/home/data/home_mock_data.dart

import 'package:flutter/material.dart';

// ── HomeTrayData ──────────────────────────────────────────────────────────────
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

// ── TravelerPreview ───────────────────────────────────────────────────────────
// Used by the TravelerRail widget for the horizontal quick-scroll strip.
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

// ── HomeMatch ─────────────────────────────────────────────────────────────────
// Intermediate shape used by HeroMatchPager / HeroMatchCard.
// Built from live TripModel data via the fromTrip factory.
class HomeMatch {
  final String id;
  final String name;
  final int age;
  final String route;
  final String tripDate;
  final String imageUrl;
  final String vibeTag;
  final List<String> pills;
  final String destination;

  const HomeMatch({
    required this.id,
    required this.name,
    required this.age,
    required this.route,
    required this.tripDate,
    required this.imageUrl,
    required this.vibeTag,
    required this.pills,
    required this.destination,
  });

  static HomeMatch fromTrip({
    required String tripId,
    required String creatorName,
    required int creatorAge,
    required String destination,
    required String dates,
    required String? avatarUrl,
    required String? vibe,
    required double rating,
    required int buddyCount,
  }) {
    return HomeMatch(
      id:          tripId,
      name:        creatorName,
      age:         creatorAge,
      route:       '— → $destination',
      tripDate:    dates,
      imageUrl:    avatarUrl ?? '',
      vibeTag:     vibe ?? '✈️ Traveler',
      destination: destination,
      pills: [
        if (buddyCount > 0) '$buddyCount trips',
        dates,
        if (rating > 0) '★ $rating',
        'Verified ✓',
      ],
    );
  }
}

// ── HomeMockData ──────────────────────────────────────────────────────────────
// Static fallback data used by TravelerRail until live discovery is wired.
class HomeMockData {
  static const List<TravelerPreview> travelers = [
    TravelerPreview(
      id: '1',
      name: 'Meera',
      destination: 'Goa',
      score: '97%',
      gradient: [Color(0xFF1E4044), Color(0xFF112425)],
    ),
    TravelerPreview(
      id: '2',
      name: 'Kabir',
      destination: 'Manali',
      score: '94%',
      gradient: [Color(0xFF1A342C), Color(0xFF112425)],
    ),
    TravelerPreview(
      id: '3',
      name: 'Anika',
      destination: 'Spiti',
      score: '91%',
      gradient: [Color(0xFF36261A), Color(0xFF112425)],
    ),
    TravelerPreview(
      id: '4',
      name: 'Dev',
      destination: 'Leh',
      score: '89%',
      gradient: [Color(0xFF301E28), Color(0xFF112425)],
    ),
    TravelerPreview(
      id: '5',
      name: 'Priya',
      destination: 'Rishikesh',
      score: '86%',
      gradient: [Color(0xFF1E4044), Color(0xFF112425)],
    ),
    TravelerPreview(
      id: '6',
      name: 'Rohan',
      destination: 'Kasol',
      score: '83%',
      gradient: [Color(0xFF1A342C), Color(0xFF112425)],
    ),
  ];
}