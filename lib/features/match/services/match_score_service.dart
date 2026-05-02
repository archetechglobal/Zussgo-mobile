// lib/features/match/services/match_score_service.dart
//
// Calls the `match-score` Supabase Edge Function and caches results
// in memory for the lifetime of the app session.

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/models/profile_model.dart';
import '../../trips/models/trip_model.dart';

// ---------------------------------------------------------------------------
// Result model
// ---------------------------------------------------------------------------

class MatchScoreResult {
  final int score;
  final String label;
  final List<String> reasons;
  final String? dealbreaker;
  final bool notificationSent;

  const MatchScoreResult({
    required this.score,
    required this.label,
    required this.reasons,
    this.dealbreaker,
    this.notificationSent = false,
  });

  factory MatchScoreResult.fromMap(Map<String, dynamic> m) {
    return MatchScoreResult(
      score:            (m['score'] as num).toInt(),
      label:            m['label'] as String,
      reasons:          List<String>.from(m['reasons'] ?? []),
      dealbreaker:      m['dealbreaker'] as String?,
      notificationSent: m['notificationSent'] as bool? ?? false,
    );
  }

  bool get isTopMatch   => score >= 85;
  bool get isGreatMatch => score >= 70 && score < 85;
  bool get isGoodMatch  => score >= 55 && score < 70;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class MatchScoreService {
  final SupabaseClient _client;

  /// In-memory cache: key = "viewerId:candidateId:tripId"
  final Map<String, MatchScoreResult> _cache = {};

  MatchScoreService(this._client);

  Future<MatchScoreResult?> getScore({
    required ProfileModel viewer,
    required TripModel trip,
  }) async {
    final candidate = trip.creator;
    if (candidate == null) return null;

    final cacheKey = '${viewer.id}:${candidate.id}:${trip.id}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    try {
      final response = await _client.functions.invoke(
        'match-score',
        body: {
          'viewer':          _profileSnapshot(viewer),
          'candidate':       _profileSnapshot(candidate),
          'tripVibe':        trip.vibe,
          'tripBudget':      trip.budget,
          'tripDestination': trip.destination,
          'tripId':          trip.id,        // ← needed for notification deep-link
        },
      );

      final data = response.data;
      Map<String, dynamic> map;
      if (data is String) {
        map = jsonDecode(data) as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        map = data;
      } else {
        return null;
      }

      final result = MatchScoreResult.fromMap(map);
      _cache[cacheKey] = result;
      return result;
    } catch (e) {
      // Never crash the UI — silently return null so badge is hidden
      return null;
    }
  }

  Map<String, dynamic> _profileSnapshot(ProfileModel p) => {
    'id':            p.id,
    'name':          p.name,
    'age':           p.age,
    'baseCity':      p.baseCity,
    'vibes':         p.vibes,
    'budget':        p.budget,
    'pace':          p.pace,
    'accommodation': p.accommodation,
    'bio':           p.bio,
  };

  void clearCache() => _cache.clear();
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

final matchScoreServiceProvider = Provider<MatchScoreService>((ref) {
  return MatchScoreService(Supabase.instance.client);
});

/// Per-trip score provider — keyed by tripId.
/// Thin provider — callers use matchScoreService.getScore() directly.
final matchScoreProvider = FutureProvider.family<MatchScoreResult?, String>(
  (ref, tripId) async => null,
  name: 'matchScoreProvider',
);
