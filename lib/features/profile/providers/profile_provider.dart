// lib/features/profile/providers/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import '../models/profile_model.dart';

final profileRepositoryProvider = Provider((_) => ProfileRepository());

// ── My own profile ─────────────────────────────────────────────────────────────

class MyProfileNotifier extends AsyncNotifier<ProfileModel?> {
  @override
  Future<ProfileModel?> build() => _repo.fetchMyProfile();

  ProfileRepository get _repo =>
      ref.read(profileRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchMyProfile());
  }

  Future<void> saveSetup({
    required String name,
    required int age,
    required String baseCity,
    required String bio,
    required List<String> vibes,
    required String budget,
    required String pace,
    required String accommodation,
  }) async {
    await _repo.upsertProfile({
      'name':          name,
      'age':           age,
      'base_city':     baseCity,
      'bio':           bio,
      'vibes':         vibes,
      'budget':        budget,
      'pace':          pace,
      'accommodation': accommodation,
      'is_setup_done': true,
    });
    await refresh();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _repo.upsertProfile(data);
    await refresh();
  }
}

final myProfileProvider =
AsyncNotifierProvider<MyProfileNotifier, ProfileModel?>(
    MyProfileNotifier.new);

// ── Travelers list (for Discover / Home feed) ──────────────────────────────────

final travelersProvider = FutureProvider<List<ProfileModel>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  return repo.fetchTravelers();
});

// ── Any profile by id (for sheets) ────────────────────────────────────────────

final profileByIdProvider =
FutureProvider.family<ProfileModel?, String>((ref, id) async {
  final repo = ref.read(profileRepositoryProvider);
  return repo.fetchById(id);
});