// lib/features/home/providers/home_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../profile/models/profile_model.dart';
import '../../trips/providers/trips_provider.dart';
import '../../trips/models/trip_model.dart';

// ─── Pager page index ─────────────────────────────────────────────────────────
class HomePageIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int index) => state = index;
}

final homePageIndexProvider =
    NotifierProvider<HomePageIndexNotifier, int>(HomePageIndexNotifier.new);

// ─── Home search query ────────────────────────────────────────────────────────
// Holds the current destination the user typed in the home search bar.
// Empty string = no filter (show all travelers).
final homeSearchQueryProvider = StateProvider<String>((ref) => '');

// ─── Travelers for search destination ────────────────────────────────────────
// When query is non-empty: returns profiles of people with active trips
// matching that destination. When empty: returns all active-trip profiles.
final homeSearchTravelersProvider =
    FutureProvider.family<List<ProfileModel>, String>((ref, query) async {
  final uid = supabase.auth.currentUser?.id;
  final q   = query.trim();

  var tripQuery = supabase
      .from('trips')
      .select('creator_id')
      .eq('status', 'active');

  if (q.isNotEmpty) {
    tripQuery = tripQuery.ilike('destination', '%\$q%');
  }

  if (uid != null) tripQuery = tripQuery.neq('creator_id', uid);

  final tripRows   = await tripQuery.limit(60);
  final creatorIds = (tripRows as List)
      .map((r) => r['creator_id'] as String)
      .toSet()
      .toList();

  if (creatorIds.isEmpty) return [];

  final profiles = await supabase
      .from('profiles')
      .select('id, name, age, avatar_url, vibes, rating, base_city')
      .inFilter('id', creatorIds)
      .limit(30);

  return (profiles as List).map((e) => ProfileModel.fromMap(e)).toList();
});

// ─── Count of travelers for the current home search query ─────────────────────
final homeSearchCountProvider = FutureProvider.family<int, String>(
  (ref, query) async {
    final travelers =
        await ref.watch(homeSearchTravelersProvider(query).future);
    return travelers.length;
  },
);

// ─── AI-ranked travelers result ───────────────────────────────────────────────
// Holds the split result from aiRankedTravelersProvider:
//   topMatches  → top 5 AI-ranked profiles shown in the home hero pager
//   allMatches  → full ranked list passed to Discover tab on "See all"
class RankedTravelersResult {
  final List<ProfileModel> topMatches;
  final List<ProfileModel> allMatches;
  const RankedTravelersResult({
    required this.topMatches,
    required this.allMatches,
  });
}

// ─── AI-ranked travelers for a destination ────────────────────────────────────
// When query is non-empty:
//   1. Fetches profiles with active trips to that destination.
//   2. Calls `rank-travelers` edge function (Perplexity sonar) to score them
//      against the current user's vibes + base city.
//   3. Re-sorts allMatches by AI score; topMatches = first 5.
// When query is empty:
//   Falls back to activeTripsProvider ordering (existing behaviour).
// On any AI failure: silently returns unranked order — core flow never breaks.
final aiRankedTravelersProvider =
    FutureProvider.family<RankedTravelersResult, String>((ref, query) async {
  final uid = supabase.auth.currentUser?.id;
  final q   = query.trim();

  // ── No search query: use activeTripsProvider (existing home behaviour) ─────
  if (q.isEmpty) {
    final trips = await ref.watch(activeTripsProvider.future);
    final profiles = trips.map((t) => ProfileModel(
      id:         t.creator?.id ?? t.creatorId,
      name:       t.creator?.name,
      age:        t.creator?.age,
      avatarUrl:  t.creator?.avatarUrl,
      vibes:      t.creator?.vibes ?? [],
      rating:     t.creator?.rating ?? 0.0,
      baseCity:   t.creator?.baseCity,
      buddyCount: t.creator?.buddyCount ?? 0,
    )).toList();
    return RankedTravelersResult(
      topMatches: profiles.take(5).toList(),
      allMatches: profiles,
    );
  }

  // ── With search query: fetch travelers going to that destination ───────────
  var tripQuery = supabase
      .from('trips')
      .select('creator_id, destination, dates, vibe, id')
      .eq('status', 'active')
      .ilike('destination', '%\$q%');

  if (uid != null) tripQuery = tripQuery.neq('creator_id', uid);

  final tripRows = await tripQuery.limit(60);
  if ((tripRows as List).isEmpty) {
    return const RankedTravelersResult(topMatches: [], allMatches: []);
  }

  // Unique creator IDs
  final creatorIds = tripRows
      .map((r) => r['creator_id'] as String)
      .toSet()
      .toList();

  // Build a quick lookup: creatorId → first matching trip row
  final tripMap = <String, Map<String, dynamic>>{};
  for (final r in tripRows) {
    final cid = r['creator_id'] as String;
    tripMap.putIfAbsent(cid, () => r);
  }

  // Fetch profiles
  final profileRows = await supabase
      .from('profiles')
      .select('id, name, age, avatar_url, vibes, rating, base_city, bio')
      .inFilter('id', creatorIds)
      .limit(40);

  final allProfiles = (profileRows as List)
      .map((e) => ProfileModel.fromMap(e))
      .toList();

  // ── Fetch current user's profile for AI context ───────────────────────────
  Map<String, dynamic> myProfile = {};
  if (uid != null) {
    final myRow = await supabase
        .from('profiles')
        .select('vibes, base_city, bio, budget, pace')
        .eq('id', uid)
        .maybeSingle();
    if (myRow != null) myProfile = myRow;
  }

  // ── Call AI ranking edge function ─────────────────────────────────────────
  try {
    final response = await Supabase.instance.client.functions.invoke(
      'rank-travelers',
      body: {
        'destination': q,
        'current_user': myProfile,
        'candidates': allProfiles.map((p) => {
          'id':        p.id,
          'vibes':     p.vibes,
          'base_city': p.baseCity ?? '',
          'bio':       p.bio ?? '',
        }).toList(),
      },
    );

    final ranked = (response.data['ranked'] as List? ?? []);
    if (ranked.isNotEmpty) {
      final scoreMap = <String, double>{
        for (final r in ranked)
          r['id'] as String: (r['score'] as num).toDouble()
      };
      allProfiles.sort((a, b) =>
          (scoreMap[b.id] ?? 0.0).compareTo(scoreMap[a.id] ?? 0.0));
    }
  } catch (_) {
    // AI failed — silently fall back to unranked order
  }

  return RankedTravelersResult(
    topMatches: allProfiles.take(5).toList(),
    allMatches: allProfiles,
  );
});
