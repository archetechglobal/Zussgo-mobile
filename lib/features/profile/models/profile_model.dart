// lib/features/profile/models/profile_model.dart

import 'package:flutter/material.dart';

class TravelLogEntry {
  final String id;
  final String destination;
  final String? companions;
  final String? imageUrl;

  const TravelLogEntry({
    required this.id,
    required this.destination,
    this.companions,
    this.imageUrl,
  });

  factory TravelLogEntry.fromMap(Map<String, dynamic> m) => TravelLogEntry(
    id:          m['id'] as String,
    destination: m['destination'] as String,
    companions:  m['companions'] as String?,
    imageUrl:    m['image_url'] as String?,
  );
}

class ReviewModel {
  final String id;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final String tripLabel;
  final int stars;
  final List<String> tags;
  final String? body;

  const ReviewModel({
    required this.id,
    required this.reviewerName,
    this.reviewerAvatarUrl,
    required this.tripLabel,
    required this.stars,
    required this.tags,
    this.body,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> m) {
    final reviewer = m['reviewer'] as Map<String, dynamic>?;
    return ReviewModel(
      id:               m['id'] as String,
      reviewerName:     reviewer?['name'] as String? ?? 'Anonymous',
      reviewerAvatarUrl: reviewer?['avatar_url'] as String?,
      tripLabel:        'Trip',
      stars:            m['stars'] as int,
      tags:             List<String>.from(m['tags'] ?? []),
      body:             m['body'] as String?,
    );
  }
}

class ProfileModel {
  final String id;
  final String name;
  final int? age;
  final String? baseCity;
  final String? bio;
  final String? avatarUrl;
  final String? phone;
  final List<String> vibes;
  final String? budget;
  final String? pace;
  final String? accommodation;
  final double rating;
  final int tripCount;
  final int buddyCount;
  final bool isSetupDone;
  final List<TravelLogEntry> travelLog;
  final List<ReviewModel> reviews;

  const ProfileModel({
    required this.id,
    required this.name,
    this.age,
    this.baseCity,
    this.bio,
    this.avatarUrl,
    this.phone,
    this.vibes = const [],
    this.budget,
    this.pace,
    this.accommodation,
    this.rating = 0,
    this.tripCount = 0,
    this.buddyCount = 0,
    this.isSetupDone = false,
    this.travelLog = const [],
    this.reviews = const [],
  });

  factory ProfileModel.fromMap(Map<String, dynamic> m) {
    return ProfileModel(
      id:            m['id'] as String,
      name:          m['name'] as String? ?? 'Traveler',
      age:           m['age'] as int?,
      baseCity:      m['base_city'] as String?,
      bio:           m['bio'] as String?,
      avatarUrl:     m['avatar_url'] as String?,
      phone:         m['phone'] as String?,
      vibes:         List<String>.from(m['vibes'] ?? []),
      budget:        m['budget'] as String?,
      pace:          m['pace'] as String?,
      accommodation: m['accommodation'] as String?,
      rating:        (m['rating'] as num?)?.toDouble() ?? 0,
      tripCount:     m['trip_count'] as int? ?? 0,
      buddyCount:    m['buddy_count'] as int? ?? 0,
      isSetupDone:   m['is_setup_done'] as bool? ?? false,
      travelLog: (m['travel_log'] as List? ?? [])
          .map((e) => TravelLogEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      reviews: (m['reviews_received'] as List? ?? [])
          .map((e) => ReviewModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Avatar initial fallback
  String get avatarInitial =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  // Colour based on name hash — consistent per user
  Color get avatarColor {
    const palette = [
      Color(0xFF58DAD0), Color(0xFFF7B84E), Color(0xFFB57BFF),
      Color(0xFF1EC9B8), Color(0xFF9FD9BE), Color(0xFFFFB3C1),
    ];
    return palette[name.codeUnits.fold(0, (a, b) => a + b) % palette.length];
  }

  ProfileModel copyWith({
    String? name, int? age, String? baseCity, String? bio,
    String? avatarUrl, List<String>? vibes, String? budget,
    String? pace, String? accommodation, bool? isSetupDone,
  }) => ProfileModel(
    id: id, phone: phone,
    name:          name          ?? this.name,
    age:           age           ?? this.age,
    baseCity:      baseCity      ?? this.baseCity,
    bio:           bio           ?? this.bio,
    avatarUrl:     avatarUrl     ?? this.avatarUrl,
    vibes:         vibes         ?? this.vibes,
    budget:        budget        ?? this.budget,
    pace:          pace          ?? this.pace,
    accommodation: accommodation ?? this.accommodation,
    isSetupDone:   isSetupDone   ?? this.isSetupDone,
    rating: rating, tripCount: tripCount,
    buddyCount: buddyCount,
    travelLog: travelLog, reviews: reviews,
  );
}