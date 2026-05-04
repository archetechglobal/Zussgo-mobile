import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';

class AuthRepository {
  // ── Email / Password ──────────────────────────────────────────────────────

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

  // ── Google OAuth ──────────────────────────────────────────────────────────

  /// Returns the AuthResponse plus Google display info and a new-user flag.
  /// [isNewUser] is true when no profiles row existed before this sign-in.
  Future<
      ({
        AuthResponse response,
        bool isNewUser,
        String displayName,
        String photoUrl
      })> signInWithGoogle() async {
    const webClientId =
        '438683605771-m47adu01tf5qq1p1km9utklbam9vgt4q.apps.googleusercontent.com';

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

    final response = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final user = response.user!;
    final meta = user.userMetadata ?? {};

    final displayName = (meta['name'] as String? ??
            meta['full_name'] as String? ??
            googleUser.displayName ??
            '')
        .trim();

    final photoUrl = (meta['picture'] as String? ??
            meta['avatar_url'] as String? ??
            googleUser.photoUrl ??
            '')
        .trim();

    // Check if a profiles row already exists → determines new vs returning
    final existing = await supabase
        .from('profiles')
        .select('id, avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    final isNewUser = existing == null;

    // Seed photo for new users or if they have no custom photo yet
    if (photoUrl.isNotEmpty) {
      final hasCustomPhoto =
          existing != null && (existing['avatar_url'] as String? ?? '').isNotEmpty;
      if (!hasCustomPhoto) {
        await supabase
            .from('profiles')
            .upsert({'id': user.id, 'avatar_url': photoUrl});
      }
    }

    return (
      response: response,
      isNewUser: isNewUser,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  // ── Phone / OTP ───────────────────────────────────────────────────────────

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

  // ── Resend verification ───────────────────────────────────────────────────

  Future<void> resendEmailVerification(String email) async {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ── Getters ───────────────────────────────────────────────────────────────

  User? get currentUser => supabase.auth.currentUser;
  Session? get currentSession => supabase.auth.currentSession;
}
