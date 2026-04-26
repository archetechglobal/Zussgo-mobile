// lib/features/trips/data/trips_repository.dart

import '../../../core/supabase/supabase_client.dart';
import '../models/trip_model.dart';

class TripsRepository {
  static const _joinQuery =
      '*, creator:profiles!creator_id(id, name, avatar_url, base_city, vibes, rating, age, trust_score)';

  // ── Create a trip ─────────────────────────────────────────────────────────
  Future<TripModel> createTrip({
    required String destination,
    required String dates,
    String? vibe,
    String? budget,
    String? intent,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    final data = await supabase.from('trips').insert({
      'creator_id':  uid,
      'destination': destination,
      'dates':       dates,
      'vibe':        vibe,
      'budget':      budget,
      'intent':      intent,
      'status':      'active',
    }).select(_joinQuery).single();
    return TripModel.fromMap(data);
  }

  // ── Fetch active trips (discover / home hero feed) ─────────────────────────
  Future<List<TripModel>> fetchActiveTrips({int limit = 30}) async {
    final uid = supabase.auth.currentUser?.id;
    var query = supabase
        .from('trips')
        .select(_joinQuery)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(limit);

    final data = await (uid != null ? query.neq('creator_id', uid) : query);
    return (data as List).map((e) => TripModel.fromMap(e)).toList();
  }

  // ── Fetch my trips ────────────────────────────────────────────────────────
  Future<List<TripModel>> fetchMyTrips() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('trips')
        .select(_joinQuery)
        .eq('creator_id', uid)
        .order('created_at', ascending: false);
    return (data as List).map((e) => TripModel.fromMap(e)).toList();
  }

  // ── Fetch trips user has joined ───────────────────────────────────────────
  Future<List<TripModel>> fetchJoinedTrips() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('trip_members')
        .select('trip:trips($_joinQuery)')
        .eq('user_id', uid)
        .eq('status', 'accepted');
    return (data as List)
        .map((e) => TripModel.fromMap(e['trip'] as Map<String, dynamic>))
        .toList();
  }

  // ── Request to join a trip ────────────────────────────────────────────────
  Future<void> requestJoin(String tripId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    await supabase.from('trip_members').upsert({
      'trip_id': tripId,
      'user_id': uid,
      'status':  'pending',
    });
  }

  // ── End a trip ────────────────────────────────────────────────────────────
  Future<void> endTrip(String tripId) async {
    await supabase.from('trips')
        .update({'status': 'ended'})
        .eq('id', tripId);
  }

  // ── Get pending join requests for my trips ────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchPendingRequests() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('trip_members')
        .select('*, trip:trips!trip_id(destination, dates), requester:profiles!user_id(id, name, avatar_url)')
        .eq('status', 'pending')
        .eq('trips.creator_id', uid);
    return List<Map<String, dynamic>>.from(data);
  }

  // ── Accept / reject join request ──────────────────────────────────────────
  Future<void> respondToRequest({
    required String tripId,
    required String userId,
    required bool accept,
  }) async {
    await supabase.from('trip_members').update({
      'status': accept ? 'accepted' : 'rejected',
    })
        .eq('trip_id', tripId)
        .eq('user_id', userId);
  }
}