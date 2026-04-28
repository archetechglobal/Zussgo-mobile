// lib/features/explore/providers/explore_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../profile/models/profile_model.dart';
import '../../trips/models/trip_model.dart';

// ─── People going to a destination ───────────────────────────────────────────
// Returns up to 20 profiles that have an active trip to [destination].
// Excludes the current user.

final peopleGoingToProvider =
    FutureProvider.family<List<ProfileModel>, String>((ref, destination) async {
  final uid = supabase.auth.currentUser?.id;

  // Step 1: get trip creator_ids for this destination
  var query = supabase
      .from('trips')
      .select('creator_id')
      .eq('status', 'active')
      .ilike('destination', '%$destination%');

  if (uid != null) {
    query = query.neq('creator_id', uid);
  }

  final tripRows = await query.limit(50);
  final creatorIds = (tripRows as List)
      .map((r) => r['creator_id'] as String)
      .toSet()
      .toList();

  if (creatorIds.isEmpty) return [];

  // Step 2: fetch profiles for those creator_ids
  final profiles = await supabase
      .from('profiles')
      .select('id, name, age, avatar_url, vibes, rating, base_city')
      .inFilter('id', creatorIds)
      .limit(20);

  return (profiles as List).map((e) => ProfileModel.fromMap(e)).toList();
});

// ─── Open trips to join for a destination ────────────────────────────────────
// Returns up to 10 active trips for [destination] created by other users.

final openTripsForProvider =
    FutureProvider.family<List<TripModel>, String>((ref, destination) async {
  final uid = supabase.auth.currentUser?.id;

  var query = supabase
      .from('trips')
      .select(
          '*, creator:creator_id(id, name, avatar_url, base_city, vibes, rating, age)')
      .eq('status', 'active')
      .ilike('destination', '%$destination%');

  if (uid != null) {
    query = query.neq('creator_id', uid);
  }

  final data = await query
      .order('created_at', ascending: false)
      .limit(10);

  return (data as List).map((e) => TripModel.fromMap(e)).toList();
});
