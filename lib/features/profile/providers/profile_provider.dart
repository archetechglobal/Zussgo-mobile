// lib/features/profile/providers/profile_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel?>> {
  final ProfileRepository _repo;
  final String _userId;

  ProfileNotifier(this._repo, this._userId) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _repo.getProfile(_userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Called from ProfileSetupScreen after onboarding steps complete.
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
    final profile = ProfileModel(
      id:            _userId,
      name:          name,
      age:           age,
      baseCity:      baseCity,
      bio:           bio,
      vibes:         vibes,
      budget:        budget,
      pace:          pace,
      accommodation: accommodation,
      isSetupDone:   true,
    );
    await _repo.upsertProfile(profile);
    state = AsyncValue.data(profile);
  }

  /// Called from EditProfileScreen to upload a new avatar.
  Future<void> uploadAvatar(File file) async {
    try {
      final url = await _repo.uploadAvatar(userId: _userId, file: file);
      final current = state.value;
      if (current != null && url != null) {
        final updated = current.copyWith(avatarUrl: url);
        await _repo.upsertProfile(updated);
        state = AsyncValue.data(updated);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();
}

/// The single source-of-truth provider for the logged-in user's profile.
final myProfileProvider =
StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel?>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return ProfileNotifier(ref.watch(profileRepositoryProvider), userId);
});

/// Provider to get any user's profile by ID (for profile sheets, etc.)
final userProfileProvider =
FutureProvider.family<ProfileModel?, String>((ref, userId) async {
  return ref.watch(profileRepositoryProvider).getProfile(userId);
});