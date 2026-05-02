// lib/features/trips/providers/trips_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/trips_repository.dart';
import '../models/trip_model.dart';

final tripsRepositoryProvider = Provider((_) => TripsRepository());

/// All active trips from other users.
/// Used in home hero pager and Match → Discover tab.
/// keepAlive: survives tab switches. Auto-invalidates after 5 min so data
/// stays fresh without hammering Supabase on every render.
final activeTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), link.close);
  return ref.read(tripsRepositoryProvider).fetchActiveTrips();
});

/// Trips I created.
/// keepAlive: session-scoped — only invalidated when user creates/deletes a trip
/// (CreateTripNotifier calls ref.invalidate after success).
final myTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 10), link.close);
  return ref.read(tripsRepositoryProvider).fetchMyTrips();
});

/// Trips I've joined via an accepted connection.
final joinedTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), link.close);
  return ref.read(tripsRepositoryProvider).fetchJoinedTrips();
});

/// Pending companion requests on MY trips.
/// Shorter TTL — needs to feel responsive when someone sends a request.
final tripPendingRequestsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 2), link.close);
  return ref.read(tripsRepositoryProvider).fetchPendingRequests();
});

/// Create trip notifier.
/// After a successful create:
///   1. Invalidates myTripsProvider + activeTripsProvider so feeds update immediately.
///   2. Non-blocking invokes the AI match + notification edge function.
class CreateTripNotifier extends StateNotifier<AsyncValue<TripModel?>> {
  final TripsRepository _repo;
  final Ref _ref;

  CreateTripNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  Future<TripModel?> create({
    required String destination,
    required String dates,
    DateTime? startDate,
    DateTime? endDate,
    String? vibe,
    String? budget,
    String? intent,
  }) async {
    state = const AsyncValue.loading();
    try {
      final trip = await _repo.createTrip(
        destination: destination,
        dates:       dates,
        startDate:   startDate,
        endDate:     endDate,
        vibe:        vibe,
        budget:      budget,
        intent:      intent,
      );
      state = AsyncValue.data(trip);

      // Bust the cache so home + discover reflect the new trip immediately
      _ref.invalidate(myTripsProvider);
      _ref.invalidate(activeTripsProvider);

      // Trigger AI matching + FCM notifications — fire-and-forget, never
      // blocks or fails the trip creation from the user's perspective.
      Supabase.instance.client.functions
          .invoke(
            'notify-trip-matches',
            body: {
              'trip_id':     trip.id,
              'destination': destination,
              'vibe':        vibe ?? '',
              'budget':      budget ?? '',
              'intent':      intent ?? '',
            },
          )
          .catchError((_) {}); // silent — core flow must never fail

      return trip;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final createTripProvider =
    StateNotifierProvider<CreateTripNotifier, AsyncValue<TripModel?>>((ref) {
  return CreateTripNotifier(ref.watch(tripsRepositoryProvider), ref);
});
