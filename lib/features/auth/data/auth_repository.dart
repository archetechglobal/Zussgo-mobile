import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';

class AuthRepository {
  // ── Email sign up — sends verification email ───────────────────────────────
  Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'zussgo://auth/callback',
      data: {
        'name': name,
        'phone': phone,
      },
    );
  }

  // ── Email sign in ──────────────────────────────────────────────────────────
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Resend verification email ──────────────────────────────────────────────
  Future<void> resendVerificationEmail({required String email}) async {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: 'zussgo://auth/callback',
    );
  }

  // ── Phone OTP — send ───────────────────────────────────────────────────────
  Future<void> sendOtp({required String phone}) async {
    await supabase.auth.signInWithOtp(phone: phone);
  }

  // ── Phone OTP — verify ─────────────────────────────────────────────────────
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return await supabase.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ── Current user ──────────────────────────────────────────────────────────
  User? get currentUser => supabase.auth.currentUser;

  // ── Is email verified ──────────────────────────────────────────────────────
  bool get isEmailVerified =>
      supabase.auth.currentUser?.emailConfirmedAt != null;

  // ── Auth state stream ──────────────────────────────────────────────────────
  Stream<AuthState> get authStateStream =>
      supabase.auth.onAuthStateChange;
}