// lib/features/profile/data/profile_repository.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  // ── Read ───────────────────────────────────────────────────────────────────
  Future<ProfileModel?> fetchMyProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;
    return getProfile(uid);
  }

  Future<ProfileModel?> getProfile(String userId) async {
    final data = await supabase
        .from(AppConstants.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  /// Alias for [getProfile].
  Future<ProfileModel?> fetchProfileById(String userId) => getProfile(userId);

  // ── Write ──────────────────────────────────────────────────────────────────
  Future<void> upsertProfile(ProfileModel profile) async {
    await supabase
        .from(AppConstants.profilesTable)
        .upsert(profile.toJson(), onConflict: 'id');
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final data = await supabase
        .from(AppConstants.profilesTable)
        .update(profile.toJson()..remove('id'))
        .eq('id', profile.id)
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }

  Future<void> markSetupDone(String userId) async {
    await supabase
        .from(AppConstants.profilesTable)
        .update({'is_setup_done': true})
        .eq('id', userId);
  }

  // ── Avatar ─────────────────────────────────────────────────────────────────
  Future<String?> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    final ext  = file.path.split('.').last;
    final path = '$userId/avatar.$ext';
    await supabase.storage
        .from(AppConstants.avatarsBucket)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));
    return supabase.storage
        .from(AppConstants.avatarsBucket)
        .getPublicUrl(path);
  }

  // ── Discover ───────────────────────────────────────────────────────────────
  Future<List<ProfileModel>> getDiscoverProfiles({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await supabase
        .from(AppConstants.profilesTable)
        .select()
        .eq('is_setup_done', true)
        .neq('id', currentUserId)
        .range(offset, offset + limit - 1);
    return (data as List).map((e) => ProfileModel.fromJson(e)).toList();
  }
}