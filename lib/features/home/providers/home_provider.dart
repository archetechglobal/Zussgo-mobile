// lib/features/home/providers/home_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../profile/models/profile_model.dart';

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
    tripQuery = tripQuery.ilike('destination', '%$q%');
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
