// lib/features/explore/data/explore_data.dart

import 'package:flutter/material.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class ExploreDestination {
  final String id;
  final String name;
  final String region;
  final String state;
  final String imageUrl;
  final int travelerCount;
  final String dateRange;
  final String topVibe;
  final Color nodeColor;
  final double mapX; // 0.0–1.0 relative to map width
  final double mapY; // 0.0–1.0 relative to map height
  final List<String> categories;
  final List<ExploreProfile> topTravelers;

  // ── Rich detail fields ────────────────────────────────────────────────────
  final String description;
  final List<String> highlights;
  final String bestTime;
  final List<String> moodTags;
  final String costHint;
  final String badge;
  final bool isOriginCity;

  const ExploreDestination({
    this.id = '',
    required this.name,
    required this.region,
    this.state = '',
    required this.imageUrl,
    required this.travelerCount,
    required this.dateRange,
    required this.topVibe,
    required this.nodeColor,
    required this.mapX,
    required this.mapY,
    required this.categories,
    required this.topTravelers,
    this.description = '',
    this.highlights = const [],
    this.bestTime = '',
    this.moodTags = const [],
    this.costHint = '',
    this.badge = '',
    this.isOriginCity = false,
  });

  /// Build from a Supabase row map.
  /// [travelerCount], [dateRange], and [topTravelers] are injected by the
  /// provider after cross-referencing the trips table.
  factory ExploreDestination.fromMap(
    Map<String, dynamic> map, {
    int travelerCount = 0,
    String dateRange = '',
    List<ExploreProfile> topTravelers = const [],
  }) {
    Color hexToColor(String hex) {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
      return const Color(0xFF1EC9B8);
    }

    return ExploreDestination(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      region: map['region'] as String? ?? '',
      state: map['state'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      travelerCount: travelerCount,
      dateRange: dateRange,
      topVibe: map['top_vibe'] as String? ?? '',
      nodeColor: hexToColor(map['node_color'] as String? ?? '#1EC9B8'),
      mapX: (map['map_x'] as num?)?.toDouble() ?? 0.5,
      mapY: (map['map_y'] as num?)?.toDouble() ?? 0.5,
      categories: List<String>.from(map['categories'] as List? ?? []),
      topTravelers: topTravelers,
      description: map['description'] as String? ?? '',
      highlights: List<String>.from(map['highlights'] as List? ?? []),
      bestTime: map['best_time'] as String? ?? '',
      moodTags: List<String>.from(map['mood_tags'] as List? ?? []),
      costHint: map['cost_hint'] as String? ?? '',
      badge: map['badge'] as String? ?? '',
      isOriginCity: map['is_origin_city'] as bool? ?? false,
    );
  }
}

class ExploreProfile {
  final String initial;
  final String name;
  final String from;
  final String dates;
  final int matchPct;
  final Color color;

  const ExploreProfile({
    required this.initial,
    required this.name,
    required this.from,
    required this.dates,
    required this.matchPct,
    required this.color,
  });
}

/// Named flow arc between two destination nodes on the map.
class ExploreFlow {
  final String fromName;
  final String toName;

  const ExploreFlow(this.fromName, this.toName);
}

// ─── Filter categories ────────────────────────────────────────────────────────

const exploreCategories = [
  (label: 'All',       icon: Icons.public_rounded),
  (label: 'Beaches',   icon: Icons.beach_access_rounded),
  (label: 'Mountains', icon: Icons.landscape_rounded),
  (label: 'Heritage',  icon: Icons.account_balance_rounded),
  (label: 'Party',     icon: Icons.celebration_rounded),
  (label: 'Budget',    icon: Icons.savings_rounded),
  (label: 'Spiritual', icon: Icons.self_improvement_rounded),
  (label: 'Wildlife',  icon: Icons.forest_rounded),
  (label: 'Offbeat',   icon: Icons.explore_rounded),
];
