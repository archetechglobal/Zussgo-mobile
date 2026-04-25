// lib/features/trips/data/trips_repository.dart

import '../../../core/supabase/supabase_client.dart';
import '../models/trip_model.dart';

class TripsRepository {
  // ── Create a trip ──────────────────────────────────────────────────────────
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
    }).select().single();
    return TripModel.fromMap(data);
  }

  // ── Fetch active trips (for discover/explore) ──────────────────────────────
  Future<List<TripModel>> fetchActiveTrips({int limit = 30}) async {
    final uid = supabase.auth.currentUser?.id;

    final filter = uid != null
        ? supabase
        .from('trips')
        .select('*, creator:creator_id(id, name, avatar_url, base_city, vibes, rating, age)')
        .eq('status', 'active')
        .neq('creator_id', uid)
        : supabase
        .from('trips')
        .select('*, creator:creator_id(id, name, avatar_url, base_city, vibes, rating, age)')
        .eq('status', 'active');

    final data = await filter
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => TripModel.fromMap(e)).toList();
  }

  // ── Fetch my trips ─────────────────────────────────────────────────────────
  Future<List<TripModel>> fetchMyTrips() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('trips')
        .select('*')
        .eq('creator_id', uid)
        .order('created_at', ascending: false);
    return (data as List).map((e) => TripModel.fromMap(e)).toList();
  }

  // ── End a trip ─────────────────────────────────────────────────────────────
  Future<void> endTrip(String tripId) async {
    await supabase.from('trips').update({'status': 'ended'}).eq('id', tripId);
  }
}