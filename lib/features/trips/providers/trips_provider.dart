// lib/features/trips/providers/trips_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/trips_repository.dart';
import '../models/trip_model.dart';

final tripsRepositoryProvider = Provider((_) => TripsRepository());

// ── Active trips feed ──────────────────────────────────────────────────────────
final activeTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  return ref.read(tripsRepositoryProvider).fetchActiveTrips();
});

// ── My trips ───────────────────────────────────────────────────────────────────
final myTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  return ref.read(tripsRepositoryProvider).fetchMyTrips();
});

// ── Create trip notifier ───────────────────────────────────────────────────────
class CreateTripNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<TripModel> create({
    required String destination,
    required String dates,
    String? vibe,
    String? budget,
    String? intent,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() =>
        ref.read(tripsRepositoryProvider).createTrip(
          destination: destination,
          dates: dates,
          vibe: vibe,
          budget: budget,
          intent: intent,
        ));
    state = result;
    // Refresh active trips
    ref.invalidate(activeTripsProvider);
    ref.invalidate(myTripsProvider);
    return result.value!;
  }
}

final createTripProvider =
AsyncNotifierProvider<CreateTripNotifier, void>(CreateTripNotifier.new);