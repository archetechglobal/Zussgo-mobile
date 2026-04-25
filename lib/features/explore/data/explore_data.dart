// lib/features/explore/data/explore_data.dart

import 'package:flutter/material.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class ExploreDestination {
  final String name;
  final String region;
  final String imageUrl;
  final int travelerCount;
  final String dateRange;
  final String topVibe;
  final Color nodeColor;
  final double mapX; // 0.0–1.0 relative to map width
  final double mapY; // 0.0–1.0 relative to map height
  final List<String> categories; // 'beaches','mountains','heritage','budget','party'
  final List<ExploreProfile> topTravelers;

  const ExploreDestination({
    required this.name,
    required this.region,
    required this.imageUrl,
    required this.travelerCount,
    required this.dateRange,
    required this.topVibe,
    required this.nodeColor,
    required this.mapX,
    required this.mapY,
    required this.categories,
    required this.topTravelers,
  });
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

class ExploreFlow {
  final int fromIndex;
  final int toIndex;

  const ExploreFlow(this.fromIndex, this.toIndex);
}

// ─── Constants ────────────────────────────────────────────────────────────────

const _teal  = Color(0xFF1EC9B8);
const _teal2 = Color(0xFF58DAD0);
const _gold  = Color(0xFFF7B84E);
const _purple = Color(0xFFB57BFF);
const _rose  = Color(0xFFFFB3C1);

// ─── Mock data ────────────────────────────────────────────────────────────────

const exploreDestinations = <ExploreDestination>[
  ExploreDestination(
    name: 'Goa',
    region: 'Goa, India',
    imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=600&q=80',
    travelerCount: 28,
    dateRange: 'May 10–20',
    topVibe: '🌊 Beach & Party',
    nodeColor: _teal,
    mapX: 0.27, mapY: 0.60,
    categories: ['beaches', 'party', 'budget'],
    topTravelers: [
      ExploreProfile(initial: 'M', name: 'Meera R.', from: 'Pune', dates: 'May 10', matchPct: 97, color: _teal2),
      ExploreProfile(initial: 'K', name: 'Kabir D.', from: 'Mumbai', dates: 'May 12', matchPct: 94, color: _gold),
      ExploreProfile(initial: 'A', name: 'Anika S.', from: 'Delhi', dates: 'May 11', matchPct: 91, color: _purple),
    ],
  ),
  ExploreDestination(
    name: 'Spiti Valley',
    region: 'Himachal Pradesh',
    imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=600&q=80',
    travelerCount: 14,
    dateRange: 'May 10–18',
    topVibe: '🏔 High Altitude',
    nodeColor: _gold,
    mapX: 0.44, mapY: 0.10,
    categories: ['mountains', 'adventure'],
    topTravelers: [
      ExploreProfile(initial: 'A', name: 'Arjun K.', from: 'Kolkata', dates: 'May 10', matchPct: 93, color: _gold),
      ExploreProfile(initial: 'P', name: 'Priya K.', from: 'Bangalore', dates: 'May 12', matchPct: 89, color: _teal2),
    ],
  ),
  ExploreDestination(
    name: 'Kerala',
    region: 'Kerala, India',
    imageUrl: 'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?auto=format&fit=crop&w=600&q=80',
    travelerCount: 19,
    dateRange: 'May 20–25',
    topVibe: '🌿 Backwaters',
    nodeColor: _teal2,
    mapX: 0.35, mapY: 0.80,
    categories: ['beaches', 'heritage', 'budget'],
    topTravelers: [
      ExploreProfile(initial: 'D', name: 'Dev S.', from: 'Bangalore', dates: 'May 20', matchPct: 88, color: _gold),
      ExploreProfile(initial: 'S', name: 'Sara J.', from: 'Jaipur', dates: 'May 21', matchPct: 85, color: _teal2),
    ],
  ),
  ExploreDestination(
    name: 'Manali',
    region: 'Himachal Pradesh',
    imageUrl: 'https://images.unsplash.com/photo-1623143521360-1e5ce6c9657b?auto=format&fit=crop&w=600&q=80',
    travelerCount: 11,
    dateRange: 'Jun 1–7',
    topVibe: '🏔 Trek & Chill',
    nodeColor: _purple,
    mapX: 0.40, mapY: 0.13,
    categories: ['mountains', 'adventure', 'budget'],
    topTravelers: [
      ExploreProfile(initial: 'R', name: 'Rohan M.', from: 'Hyderabad', dates: 'Jun 1', matchPct: 85, color: _gold),
      ExploreProfile(initial: 'N', name: 'Neha P.', from: 'Delhi', dates: 'Jun 2', matchPct: 82, color: _purple),
    ],
  ),
  ExploreDestination(
    name: 'Rajasthan',
    region: 'Rajasthan, India',
    imageUrl: 'https://images.unsplash.com/photo-1477587458883-47145ed31282?auto=format&fit=crop&w=600&q=80',
    travelerCount: 16,
    dateRange: 'May 14–20',
    topVibe: '🏛 Heritage',
    nodeColor: _gold,
    mapX: 0.30, mapY: 0.30,
    categories: ['heritage', 'culture'],
    topTravelers: [
      ExploreProfile(initial: 'A', name: 'Anika S.', from: 'Delhi', dates: 'May 14', matchPct: 91, color: _purple),
      ExploreProfile(initial: 'S', name: 'Sara J.', from: 'Jaipur', dates: 'May 15', matchPct: 87, color: _teal2),
    ],
  ),
  ExploreDestination(
    name: 'Andaman',
    region: 'Andaman Islands',
    imageUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80',
    travelerCount: 9,
    dateRange: 'May 18–25',
    topVibe: '🏝 Island Life',
    nodeColor: _teal,
    mapX: 0.75, mapY: 0.68,
    categories: ['beaches', 'adventure'],
    topTravelers: [
      ExploreProfile(initial: 'M', name: 'Meera R.', from: 'Pune', dates: 'May 18', matchPct: 90, color: _teal2),
    ],
  ),
  ExploreDestination(
    name: 'Varanasi',
    region: 'Uttar Pradesh',
    imageUrl: 'https://images.unsplash.com/photo-1561361058-c24cecae35ca?auto=format&fit=crop&w=600&q=80',
    travelerCount: 7,
    dateRange: 'May 22–26',
    topVibe: '🕌 Spiritual',
    nodeColor: _gold,
    mapX: 0.55, mapY: 0.33,
    categories: ['heritage', 'culture'],
    topTravelers: [
      ExploreProfile(initial: 'A', name: 'Arjun K.', from: 'Kolkata', dates: 'May 22', matchPct: 86, color: _gold),
    ],
  ),
  ExploreDestination(
    name: 'Leh Ladakh',
    region: 'Ladakh, India',
    imageUrl: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=600&q=80',
    travelerCount: 9,
    dateRange: 'Jun 5–15',
    topVibe: '🏔 Expedition',
    nodeColor: _purple,
    mapX: 0.38, mapY: 0.07,
    categories: ['mountains', 'adventure'],
    topTravelers: [
      ExploreProfile(initial: 'D', name: 'Dev S.', from: 'Bangalore', dates: 'Jun 5', matchPct: 88, color: _gold),
    ],
  ),
  // Origin cities (no travelers, just nodes for flow arcs)
  ExploreDestination(
    name: 'Mumbai',
    region: 'Maharashtra',
    imageUrl: '',
    travelerCount: 24,
    dateRange: '',
    topVibe: '',
    nodeColor: _teal,
    mapX: 0.27, mapY: 0.49,
    categories: [],
    topTravelers: [],
  ),
  ExploreDestination(
    name: 'Delhi',
    region: 'Delhi',
    imageUrl: '',
    travelerCount: 18,
    dateRange: '',
    topVibe: '',
    nodeColor: _teal2,
    mapX: 0.42, mapY: 0.23,
    categories: [],
    topTravelers: [],
  ),
  ExploreDestination(
    name: 'Bangalore',
    region: 'Karnataka',
    imageUrl: '',
    travelerCount: 16,
    dateRange: '',
    topVibe: '',
    nodeColor: _teal,
    mapX: 0.38, mapY: 0.69,
    categories: [],
    topTravelers: [],
  ),
  ExploreDestination(
    name: 'Kolkata',
    region: 'West Bengal',
    imageUrl: '',
    travelerCount: 12,
    dateRange: '',
    topVibe: '',
    nodeColor: _purple,
    mapX: 0.70, mapY: 0.36,
    categories: [],
    topTravelers: [],
  ),
  ExploreDestination(
    name: 'Hyderabad',
    region: 'Telangana',
    imageUrl: '',
    travelerCount: 14,
    dateRange: '',
    topVibe: '',
    nodeColor: _gold,
    mapX: 0.43, mapY: 0.60,
    categories: [],
    topTravelers: [],
  ),
  ExploreDestination(
    name: 'Pune',
    region: 'Maharashtra',
    imageUrl: '',
    travelerCount: 8,
    dateRange: '',
    topVibe: '',
    nodeColor: _teal2,
    mapX: 0.31, mapY: 0.52,
    categories: [],
    topTravelers: [],
  ),
];

// Destination indices (first 8 are destinations, rest are origin cities)
const exploreFlows = <ExploreFlow>[
  // Mumbai → Goa, Spiti, Kerala
  ExploreFlow(8, 0), ExploreFlow(8, 1), ExploreFlow(8, 2),
  // Delhi → Spiti, Rajasthan, Manali
  ExploreFlow(9, 1), ExploreFlow(9, 4), ExploreFlow(9, 3),
  // Bangalore → Kerala, Goa, Andaman
  ExploreFlow(10, 2), ExploreFlow(10, 0), ExploreFlow(10, 5),
  // Kolkata → Andaman, Varanasi
  ExploreFlow(11, 5), ExploreFlow(11, 6),
  // Hyderabad → Goa, Kerala
  ExploreFlow(12, 0), ExploreFlow(12, 2),
  // Pune → Goa, Manali
  ExploreFlow(13, 0), ExploreFlow(13, 3),
];

// Categories for the filter strip
const exploreCategories = [
  (label: 'All',      icon: Icons.public_rounded),
  (label: 'Beaches',  icon: Icons.beach_access_rounded),
  (label: 'Mountains',icon: Icons.landscape_rounded),
  (label: 'Heritage', icon: Icons.account_balance_rounded),
  (label: 'Party',    icon: Icons.celebration_rounded),
  (label: 'Budget',   icon: Icons.savings_rounded),
];