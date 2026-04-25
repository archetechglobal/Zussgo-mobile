// lib/features/profile/data/profile_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  // ── Fetch any profile by id ────────────────────────────────────────────────
  Future<ProfileModel?> fetchById(String userId) async {
    final data = await supabase
        .from('profiles')
        .select('*, travel_log(*), reviews_received:reviews!reviewee_id(*, reviewer:reviewer_id(name, avatar_url))')
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromMap(data);
  }

  // ── Fetch current user's own profile ──────────────────────────────────────
  Future<ProfileModel?> fetchMyProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;
    return fetchById(uid);
  }

  // ── Update profile (setup + edit) ─────────────────────────────────────────
  Future<void> upsertProfile(Map<String, dynamic> data) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    await supabase.from('profiles').upsert({'id': uid, ...data});
  }

  // ── Mark setup as complete ────────────────────────────────────────────────
  Future<void> markSetupDone() async {
    await upsertProfile({'is_setup_done': true});
  }

  // ── Check if setup is done ────────────────────────────────────────────────
  Future<bool> isSetupDone() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return false;
    final data = await supabase
        .from('profiles')
        .select('is_setup_done')
        .eq('id', uid)
        .maybeSingle();
    return data?['is_setup_done'] == true;
  }

  // ── Fetch all active travelers (for discover/match) ───────────────────────
  Future<List<ProfileModel>> fetchTravelers({int limit = 20}) async {
    final uid = supabase.auth.currentUser?.id;

    // Build filter — exclude current user if logged in
    final filter = uid != null
        ? supabase.from('profiles').select('*').eq('is_setup_done', true).neq('id', uid)
        : supabase.from('profiles').select('*').eq('is_setup_done', true);

    final data = await filter
        .order('updated_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => ProfileModel.fromMap(e)).toList();
  }

  // ── Upload avatar ─────────────────────────────────────────────────────────
  Future<String> uploadAvatar(List<int> bytes, String ext) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    final path = 'avatars/$uid.$ext';
    await supabase.storage.from('avatars').uploadBinary(
      path, bytes,
      fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
    );
    return supabase.storage.from('avatars').getPublicUrl(path);
  }
}