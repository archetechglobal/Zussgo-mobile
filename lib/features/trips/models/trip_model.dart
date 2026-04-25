// lib/features/trips/models/trip_model.dart

import 'package:flutter/material.dart';
import '../../profile/models/profile_model.dart';

class TripModel {
  final String id;
  final String creatorId;
  final String destination;
  final String dates;
  final String? vibe;
  final String? budget;
  final String? intent;
  final String status;
  final DateTime createdAt;
  final ProfileModel? creator; // joined

  const TripModel({
    required this.id,
    required this.creatorId,
    required this.destination,
    required this.dates,
    this.vibe,
    this.budget,
    this.intent,
    required this.status,
    required this.createdAt,
    this.creator,
  });

  factory TripModel.fromMap(Map<String, dynamic> m) {
    final creatorMap = m['creator'] as Map<String, dynamic>?;
    return TripModel(
      id:          m['id'] as String,
      creatorId:   m['creator_id'] as String,
      destination: m['destination'] as String,
      dates:       m['dates'] as String,
      vibe:        m['vibe'] as String?,
      budget:      m['budget'] as String?,
      intent:      m['intent'] as String?,
      status:      m['status'] as String,
      createdAt:   DateTime.parse(m['created_at'] as String),
      creator:     creatorMap != null ? ProfileModel.fromMap(creatorMap) : null,
    );
  }
}