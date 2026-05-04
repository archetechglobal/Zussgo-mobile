// lib/features/home/providers/home_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../profile/models/profile_model.dart';
import '../../trips/providers/trips_provider.dart';

// ─── Pager page index ─────────────────────────────────────────────────────────
class HomePageIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int index) => state = index;
}

final homePageIndexProvider =
    NotifierProvider<HomePageIndexNotifier, int>(HomePageIndexNotifier.new);

// ─── Home search query ────────────────────────────────────────────────────────
final homeSearchQueryProvider = StateProvider<String>((ref) => '');

// ─── Travelers for search destination ────────────────────────────────────────
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
class RankedTravelersResult {
  final List<ProfileModel> topMatches;
  final List<ProfileModel> allMatches;
  const RankedTravelersResult({
    required this.topMatches,
    required this.allMatches,
  });
}

// ─── Vibe-matched travellers (no destination query) ───────────────────────────
// Filters come BEFORE order/limit so the chain stays on
// PostgrestFilterBuilder, never on PostgrestTransformBuilder.
final vibeMatchedTravellersProvider =
    FutureProvider<RankedTravelersResult>((ref) async {
  final uid = supabase.auth.currentUser?.id;

  // ── Fetch current user's vibes ────────────────────────────────────────────
  List<String> myVibes = [];
  if (uid != null) {
    final myRow = await supabase
        .from('profiles')
        .select('vibes')
        .eq('id', uid)
        .maybeSingle();
    if (myRow != null && myRow['vibes'] != null) {
      myVibes = List<String>.from(myRow['vibes'] as List);
    }
  }

  // ── Build filter query FIRST, then transform ──────────────────────────────
  // neq / not must come before order / limit.
  var profileQuery = supabase
      .from('profiles')
      .select('id, name, age, avatar_url, vibes, rating, base_city, buddy_count')
      .not('avatar_url', 'is', null); // filter: only profiles with a photo

  if (uid != null) {
    profileQuery = profileQuery.neq('id', uid); // filter: exclude self
  }

  // Transforms (order + limit) applied last
  final rows = await profileQuery
      .order('updated_at', ascending: false)
      .limit(40);

  final profiles = (rows as List).map((e) => ProfileModel.fromMap(e)).toList();

  if (profiles.isEmpty) {
    return const RankedTravelersResult(topMatches: [], allMatches: []);
  }

  // ── Score by vibe overlap ─────────────────────────────────────────────────
  if (myVibes.isNotEmpty) {
    final myVibeSet = myVibes.map((v) => v.toLowerCase()).toSet();
    profiles.sort((a, b) {
      final aScore = a.vibes
          .where((v) => myVibeSet.contains(v.toLowerCase()))
          .length;
      final bScore = b.vibes
          .where((v) => myVibeSet.contains(v.toLowerCase()))
          .length;
      if (bScore != aScore) return bScore.compareTo(aScore);
      return (b.rating ?? 0.0).compareTo(a.rating ?? 0.0);
    });
  }

  return RankedTravelersResult(
    topMatches: profiles.take(5).toList(),
    allMatches: profiles,
  );
});

// ─── AI-ranked travelers for a destination ────────────────────────────────────
final aiRankedTravelersProvider =
    FutureProvider.family<RankedTravelersResult, String>((ref, query) async {
  final uid = supabase.auth.currentUser?.id;
  final q   = query.trim();

  // ── No search query: show best vibe matches ───────────────────────────────
  if (q.isEmpty) {
    return ref.watch(vibeMatchedTravellersProvider.future);
  }

  // ── With search query: fetch travelers going to that destination ──────────
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

  final creatorIds = tripRows
      .map((r) => r['creator_id'] as String)
      .toSet()
      .toList();

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
