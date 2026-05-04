import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';

class AuthRepository {
  // ── Email / Password ────────────────────────────────────────────────────────

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required int age,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'zussgo://auth/callback',
      data: {
        'full_name': name,
        'phone': phone,
        'age': age,
      },
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Google OAuth ─────────────────────────────────────────────────────────────
  //
  // HOW TO GET YOUR WEB CLIENT ID:
  // 1. Go to https://console.cloud.google.com/apis/credentials
  // 2. Find the OAuth 2.0 Client ID whose type is "Web application"
  //    (NOT the Android client — the Web one is what Supabase needs)
  // 3. Copy the Client ID (ends in .apps.googleusercontent.com)
  // 4. Paste it below as the value of webClientId
  // 5. Also make sure your Android SHA-1 fingerprint is registered
  //    under the Android OAuth client in the same console.

  Future<AuthResponse> signInWithGoogle() async {
    const webClientId =
        ''; // TODO: paste Web Client ID from Google Cloud Console

    assert(
      webClientId.isNotEmpty,
      'Google sign-in requires a webClientId. '
      'See the comment above signInWithGoogle() in auth_repository.dart.',
    );

    final googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth  = await googleUser.authentication;
    final idToken     = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) throw Exception('No ID token from Google');

    return await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken:    idToken,
      accessToken: accessToken,
    );
  }

  // ── Phone / OTP ─────────────────────────────────────────────────────────────

  Future<void> signInWithPhone(String phone) async {
    await supabase.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    return await supabase.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  // ── Resend verification ──────────────────────────────────────────────────────

  Future<void> resendEmailVerification(String email) async {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  // ── Sign out ─────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ── Getters ──────────────────────────────────────────────────────────────────

  User? get currentUser => supabase.auth.currentUser;
  Session? get currentSession => supabase.auth.currentSession;
}
