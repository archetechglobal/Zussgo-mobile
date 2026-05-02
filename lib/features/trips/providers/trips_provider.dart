// lib/features/trips/providers/trips_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/trips_repository.dart';
import '../models/trip_model.dart';

final tripsRepositoryProvider = Provider((_) => TripsRepository());

/// Active trips — StreamProvider backed by Supabase Realtime.
/// New trips broadcast by other users appear instantly without waiting
/// for any TTL to expire. Falls back gracefully if the channel errors.
final activeTripsProvider = StreamProvider<List<TripModel>>((ref) async* {
  final repo = ref.read(tripsRepositoryProvider);

  // Yield the initial snapshot immediately
  yield await repo.fetchActiveTrips();

  // Open a Realtime channel: re-fetch on any INSERT to the trips table
  final controller = StreamController<List<TripModel>>();
  final channel = Supabase.instance.client
      .channel('public:trips:active')
      .onPostgresChanges(
        event:    PostgresChangeEvent.insert,
        schema:   'public',
        table:    'trips',
        callback: (_) async {
          if (!controller.isClosed) {
            try {
              final fresh = await repo.fetchActiveTrips();
              controller.add(fresh);
            } catch (_) {}
          }
        },
      )
      .subscribe();

  ref.onDispose(() {
    Supabase.instance.client.removeChannel(channel);
    controller.close();
  });

  yield* controller.stream;
});

/// Trips I created.
/// keepAlive: session-scoped — only invalidated when user creates/deletes a trip.
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
///   1. Invalidates myTripsProvider so the "My Trips" tab updates immediately.
///   2. activeTripsProvider is Realtime-driven — no manual invalidate needed.
///   3. Non-blocking invokes the AI match + notification edge function.
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

      // Bust the "My Trips" cache — Realtime handles activeTripsProvider
      _ref.invalidate(myTripsProvider);

      // Fire-and-forget: AI scoring + FCM push notifications.
      // unawaited detaches the future entirely — the UI never waits on this
      // and any failure is silently swallowed via catchError.
      // Core trip creation always succeeds from the user's perspective.
      unawaited(
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
            .catchError((_) {}),
      );

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
