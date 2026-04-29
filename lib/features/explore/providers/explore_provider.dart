// lib/features/explore/providers/explore_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../profile/models/profile_model.dart';
import '../../trips/models/trip_model.dart';
import '../data/explore_data.dart';

// ─── All destinations from Supabase ──────────────────────────────────────────────
// Fetches every row from the `destinations` table, then enriches each one
// with a live traveler count cross-referenced from the `trips` table.
// UI filters/searches happen client-side over this cached list.

final destinationsProvider =
    FutureProvider<List<ExploreDestination>>((ref) async {
  // 1. Fetch all destination rows (alphabetical)
  final rows = await supabase
      .from('destinations')
      .select('*')
      .order('name', ascending: true);

  if ((rows as List).isEmpty) return [];

  // 2. Fetch live traveler counts: all active trips, grouped by destination name
  final tripCounts = await supabase
      .from('trips')
      .select('destination')
      .eq('status', 'active');

  // Build a lowercase name → count map
  final countMap = <String, int>{};
  for (final t in (tripCounts as List)) {
    final key = (t['destination'] as String? ?? '').toLowerCase().trim();
    countMap[key] = (countMap[key] ?? 0) + 1;
  }

  // 3. Build enriched ExploreDestination list
  return rows.map<ExploreDestination>((row) {
    final name = (row['name'] as String? ?? '').toLowerCase().trim();
    final count = countMap[name] ?? 0;
    return ExploreDestination.fromMap(row, travelerCount: count);
  }).toList();
});

// ─── Category-filtered destinations ─────────────────────────────────────────────
// Filters the full list by category. Origin cities are always excluded.
// Category string must match the exploreCategories label (case-insensitive).

final filteredDestinationsProvider =
    Provider.family<AsyncValue<List<ExploreDestination>>, String>(
        (ref, category) {
  final all = ref.watch(destinationsProvider);
  if (category == 'All') {
    return all.whenData(
        (list) => list.where((d) => !d.isOriginCity).toList());
  }

  return all.whenData((list) => list
      .where((d) =>
          !d.isOriginCity &&
          d.categories.any(
            (c) => c.toLowerCase() == category.toLowerCase(),
          ))
      .toList());
});

// ─── Full-text search across destinations ────────────────────────────────────
// Searches name, region, state, topVibe, and categories.
// Returns all non-origin destinations if query is empty.

final destinationSearchProvider =
    Provider.family<AsyncValue<List<ExploreDestination>>, String>(
        (ref, query) {
  final all = ref.watch(destinationsProvider);
  if (query.trim().isEmpty) {
    return all.whenData(
        (list) => list.where((d) => !d.isOriginCity).toList());
  }

  final q = query.toLowerCase();
  return all.whenData((list) => list
      .where((d) =>
          !d.isOriginCity &&
          (d.name.toLowerCase().contains(q) ||
              d.region.toLowerCase().contains(q) ||
              d.state.toLowerCase().contains(q) ||
              d.categories.any((c) => c.toLowerCase().contains(q)) ||
              d.topVibe.toLowerCase().contains(q)))
      .toList());
});

// ─── People going to a destination ──────────────────────────────────────────
// Returns up to 20 profiles with an active trip to [destination].
// Excludes the current user.

final peopleGoingToProvider =
    FutureProvider.family<List<ProfileModel>, String>((ref, destination) async {
  final uid = supabase.auth.currentUser?.id;

  var query = supabase
      .from('trips')
      .select('creator_id')
      .eq('status', 'active')
      .ilike('destination', '%$destination%');

  if (uid != null) query = query.neq('creator_id', uid);

  final tripRows = await query.limit(50);
  final creatorIds = (tripRows as List)
      .map((r) => r['creator_id'] as String)
      .toSet()
      .toList();

  if (creatorIds.isEmpty) return [];

  final profiles = await supabase
      .from('profiles')
      .select('id, name, age, avatar_url, vibes, rating, base_city')
      .inFilter('id', creatorIds)
      .limit(20);

  return (profiles as List).map((e) => ProfileModel.fromMap(e)).toList();
});

// ─── Open trips to join for a destination ──────────────────────────────────
// Returns up to 10 active trips for [destination] from other users.

final openTripsForProvider =
    FutureProvider.family<List<TripModel>, String>((ref, destination) async {
  final uid = supabase.auth.currentUser?.id;

  var query = supabase
      .from('trips')
      .select(
          '*, creator:creator_id(id, name, avatar_url, base_city, vibes, rating, age)')
      .eq('status', 'active')
      .ilike('destination', '%$destination%');

  if (uid != null) query = query.neq('creator_id', uid);

  final data = await query
      .order('created_at', ascending: false)
      .limit(10);

  return (data as List).map((e) => TripModel.fromMap(e)).toList();
});
