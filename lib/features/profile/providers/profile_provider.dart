// lib/features/profile/providers/profile_provider.dart

import 'dart:async';
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

/// Watches the Supabase auth stream and exposes the current user ID.
/// When the signed-in user changes (logout, account switch), this
/// provider emits a new value which causes [myProfileProvider] to
/// rebuild with the correct user ID — preventing stale profile data.
final _authUserIdProvider = StreamProvider<String>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (data) => data.session?.user.id ?? '',
  );
});

/// The single source-of-truth provider for the logged-in user's profile.
/// Re-creates the ProfileNotifier whenever the signed-in user changes.
final myProfileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel?>>((ref) {
  // Watch the live auth stream — rebuilds this provider on user change.
  final authAsync = ref.watch(_authUserIdProvider);
  final userId = authAsync.value ?? 
      Supabase.instance.client.auth.currentUser?.id ?? '';
  return ProfileNotifier(ref.watch(profileRepositoryProvider), userId);
});

/// Any user's profile by ID — used in profile sheets, traveler cards.
/// keepAlive: profile data rarely changes mid-session. 15-min TTL.
final userProfileProvider =
    FutureProvider.family<ProfileModel?, String>((ref, userId) async {
  final link = ref.keepAlive();
  // 15 minutes — profile data is stable within a session
  Future.delayed(const Duration(minutes: 15), link.close);
  return ref.read(profileRepositoryProvider).getProfile(userId);
});
