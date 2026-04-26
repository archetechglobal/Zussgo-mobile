import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  Future<ProfileModel?> getProfile(String userId) async {
    final data = await supabase
        .from(AppConstants.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  Future<void> upsertProfile(ProfileModel profile) async {
    await supabase
        .from(AppConstants.profilesTable)
        .upsert(profile.toJson(), onConflict: 'id');
  }

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