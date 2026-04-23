// lib/features/home/data/home_mock_data.dart

import 'package:flutter/material.dart';

class HomeMatch {
  final String name;
  final int age;
  final String route;
  final String tripDate;
  final String imageUrl;
  final String vibeTag;
  final List<String> pills;
  final String destination;

  const HomeMatch({
    required this.name,
    required this.age,
    required this.route,
    required this.tripDate,
    required this.imageUrl,
    required this.vibeTag,
    required this.pills,
    required this.destination,
  });
}

class TravelerPreview {
  final String name;
  final String destination;
  final String score;
  final List<Color> gradient;

  const TravelerPreview({
    required this.name,
    required this.destination,
    required this.score,
    required this.gradient,
  });
}

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

class HomeMockData {
  static const matches = <HomeMatch>[
    HomeMatch(
      name: 'Meera R.',
      age: 24,
      route: 'Pune → Spiti Valley',
      tripDate: 'May 10–18',
      imageUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80',
      vibeTag: '🏔️ Adventure · Top match today',
      destination: 'Kerala',
      pills: ['97% match', 'Same dates', '₹₹ Budget fit', 'Verified ✓'],
    ),
    HomeMatch(
      name: 'Anika S.',
      age: 26,
      route: 'Delhi → Jaipur',
      tripDate: 'May 14–17',
      imageUrl:
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=900&q=80',
      vibeTag: '🎨 Culture · Great energy',
      destination: 'Spiti Valley',
      pills: ['91% match', 'Weekend trip', 'Easy planner', 'Verified ✓'],
    ),
    HomeMatch(
      name: 'Priya K.',
      age: 25,
      route: 'Bangalore → Kerala',
      tripDate: 'May 20–25',
      imageUrl:
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80',
      vibeTag: '🌴 Relaxed · Safe choice',
      destination: 'Spiti Valley',
      pills: ['87% match', 'Budget aligned', 'Calm vibe', 'Verified ✓'],
    ),
  ];

  static const travelers = <TravelerPreview>[
    TravelerPreview(
      name: 'Kabir',
      destination: 'Goa',
      score: '94%',
      gradient: [Color(0xFF315E59), Color(0xFF173232)],
    ),
    TravelerPreview(
      name: 'Anika',
      destination: 'Jaipur',
      score: '91%',
      gradient: [Color(0xFF59432B), Color(0xFF2A2017)],
    ),
    TravelerPreview(
      name: 'Dev',
      destination: 'Coorg',
      score: '89%',
      gradient: [Color(0xFF274B43), Color(0xFF162E2B)],
    ),
    TravelerPreview(
      name: 'Priya',
      destination: 'Kerala',
      score: '87%',
      gradient: [Color(0xFF3B5E38), Color(0xFF1A2F1A)],
    ),
  ];

  static const trays = <HomeTrayData>[
    HomeTrayData(
      icon: Icons.luggage_rounded,
      iconColor: Color(0xFF58DAD0),
      iconBg: Color(0x2420C9B8),
      title: 'Spiti Valley trip · Live',
      subtitle: 'May 10–18 · 3 companions joined',
    ),
    HomeTrayData(
      icon: Icons.group_add_rounded,
      iconColor: Color(0xFFF7B84E),
      iconBg: Color(0x24F7B84E),
      title: 'Companion requests',
      subtitle: 'Priya S. and Rohan K. want to join',
      badge: '2',
    ),
  ];
}