import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';

// Repository singleton
final profileRepositoryProvider = Provider((_) => ProfileRepository());

// Async provider for current user's profile
final myProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  return ref.watch(profileRepositoryProvider).fetchMyProfile();
});

// Notifier for editing profile (wraps local state + save)
class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel?>> {
  final ProfileRepository _repo;
  ProfileNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repo.fetchMyProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> save(ProfileModel updated) async {
    try {
      final saved = await _repo.updateProfile(updated);
      state = AsyncValue.data(saved);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileNotifierProvider =
StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel?>>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});