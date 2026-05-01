// lib/features/trips/data/trips_repository.dart

import '../../../core/supabase/supabase_client.dart';
import '../models/trip_model.dart';

class TripsRepository {
  // ── Create ─────────────────────────────────────────────────────────────────
  // startDate / endDate are the raw DateTime objects from the calendar picker.
  // They are written as ISO date strings to the indexed DB columns so the
  // "Next 7 days" filter can use the index instead of scanning text.
  Future<TripModel> createTrip({
    required String destination,
    required String dates,          // human-readable label e.g. "May 12–15"
    DateTime? startDate,            // structured start — from calendar picker
    DateTime? endDate,              // structured end   — from calendar picker
    String? vibe,
    String? budget,
    String? intent,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');

    final payload = <String, dynamic>{
      'creator_id':  uid,
      'destination': destination,
      'dates':       dates,
      'vibe':        vibe,
      'budget':      budget,
      'intent':      intent,
    };

    // Write structured dates when available (calendar flow always provides them)
    if (startDate != null) {
      payload['start_date'] =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null) {
      payload['end_date'] =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    }

    final data = await supabase.from('trips').insert(payload).select().single();
    return TripModel.fromMap(data);
  }

  // ── Active trips (discover / home hero feed) ───────────────────────────────
  // Selects start_date so the match-screen Next-7-days chip can compare real
  // dates instead of running a regex on the text `dates` field.
  Future<List<TripModel>> fetchActiveTrips({int limit = 30}) async {
    final uid = supabase.auth.currentUser?.id;

    final filter = uid != null
        ? supabase
            .from('trips')
            .select(
              '*, '
              'creator:creator_id(id, name, avatar_url, base_city, vibes, rating, age)',
            )
            .eq('status', 'active')
            .neq('creator_id', uid)
        : supabase
            .from('trips')
            .select(
              '*, '
              'creator:creator_id(id, name, avatar_url, base_city, vibes, rating, age)',
            )
            .eq('status', 'active');

    final data = await filter
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => TripModel.fromMap(e)).toList();
  }

  // ── My created trips ───────────────────────────────────────────────────────
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

  // ── Trips I've joined (accepted connection + trip_id set) ──────────────────
  Future<List<TripModel>> fetchJoinedTrips() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];

    final connections = await supabase
        .from('connections')
        .select('trip_id')
        .eq('requester_id', uid)
        .eq('status', 'accepted')
        .not('trip_id', 'is', null);

    final tripIds = (connections as List)
        .map((e) => e['trip_id'] as String)
        .toList();

    if (tripIds.isEmpty) return [];

    final data = await supabase
        .from('trips')
        .select(
          '*, '
          'creator:creator_id(id, name, avatar_url, base_city, vibes, rating, age)',
        )
        .inFilter('id', tripIds)
        .order('created_at', ascending: false);
    return (data as List).map((e) => TripModel.fromMap(e)).toList();
  }

  // ── Pending companion requests on MY trips ─────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchPendingRequests() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];

    final data = await supabase
        .from('connections')
        .select(
          '*, '
          'requester:requester_id(id, name, avatar_url, base_city, rating), '
          'trip:trip_id(id, destination, dates)',
        )
        .eq('status', 'pending')
        .not('trip_id', 'is', null);

    final myTripIds = await supabase
        .from('trips')
        .select('id')
        .eq('creator_id', uid);

    final myIds = (myTripIds as List).map((e) => e['id'] as String).toSet();

    return (data as List)
        .where((e) => myIds.contains(e['trip_id'] as String?))
        .cast<Map<String, dynamic>>()
        .toList();
  }

  // ── End a trip ─────────────────────────────────────────────────────────────
  Future<void> endTrip(String tripId) async {
    await supabase.from('trips').update({'status': 'ended'}).eq('id', tripId);
  }
}
