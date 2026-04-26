import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip_model.dart';
import '../repositories/trips_repository.dart';
import '../supabase/supabase_client.dart';

final tripRepositoryProvider = Provider((_) => TripRepository());

// All open trips (explore)
final openTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  return ref.watch(tripRepositoryProvider).fetchOpenTrips();
});

// My created trips
final myTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) return [];
  return ref.watch(tripRepositoryProvider).fetchMyTrips(uid);
});

// My joined trips
final joinedTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) return [];
  return ref.watch(tripRepositoryProvider).fetchJoinedTrips(uid);
});