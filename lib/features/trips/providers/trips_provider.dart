// lib/features/trips/providers/trips_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/trips_repository.dart';
import '../models/trip_model.dart';

final tripsRepositoryProvider = Provider((_) => TripsRepository());

/// All active trips from other users.
/// Used in home hero pager and Match → Discover tab.
final activeTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  return ref.watch(tripsRepositoryProvider).fetchActiveTrips();
});

/// Trips I created.
final myTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  return ref.watch(tripsRepositoryProvider).fetchMyTrips();
});

/// Trips I've joined via an accepted connection.
final joinedTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  return ref.watch(tripsRepositoryProvider).fetchJoinedTrips();
});

/// Pending companion requests on MY trips.
/// Named tripPendingRequestsProvider to avoid clashing with
/// connections_provider's pendingRequestsProvider.
final tripPendingRequestsProvider =
FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(tripsRepositoryProvider).fetchPendingRequests();
});

/// Create trip notifier
class CreateTripNotifier extends StateNotifier<AsyncValue<TripModel?>> {
  final TripsRepository _repo;
  CreateTripNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<TripModel?> create({
    required String destination,
    required String dates,
    String? vibe,
    String? budget,
    String? intent,
  }) async {
    state = const AsyncValue.loading();
    try {
      final trip = await _repo.createTrip(
        destination: destination,
        dates: dates,
        vibe: vibe,
        budget: budget,
        intent: intent,
      );
      state = AsyncValue.data(trip);
      return trip;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final createTripProvider =
StateNotifierProvider<CreateTripNotifier, AsyncValue<TripModel?>>((ref) {
  return CreateTripNotifier(ref.watch(tripsRepositoryProvider));
});