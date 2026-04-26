import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../supabase/supabase_client.dart';

class ProfileRepository {
  // Fetch current user's profile
  Future<ProfileModel?> fetchMyProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  // Fetch any user's profile by id
  Future<ProfileModel?> fetchProfileById(String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  // Update profile fields
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final data = await supabase
        .from('profiles')
        .update(profile.toJson()..remove('id'))
        .eq('id', profile.id)
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }

  // Upload avatar and return public URL
  Future<String> uploadAvatar(String userId, File file) async {
    final ext = file.path.split('.').last;
    final path = '$userId/avatar.$ext';
    await supabase.storage
        .from('avatars')
        .upload(path, file, fileOptions: const FileOptions(upsert: true));
    return supabase.storage.from('avatars').getPublicUrl(path);
  }

  // Mark profile setup as complete
  Future<void> markSetupDone(String userId) async {
    await supabase
        .from('profiles')
        .update({'is_setup_done': true})
        .eq('id', userId);
  }
}