import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
      (_) => AuthRepository(),
);

// ── State ──────────────────────────────────────────────────────────────────

sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
class AuthAwaitingVerification extends AuthState {
  final String email; // so verify screen can show it + resend
  AuthAwaitingVerification(this.email);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// ── Notifier ───────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(AuthInitial());

  // ── Sign up ──────────────────────────────────────────────────────────────
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = AuthLoading();
    try {
      final response = await _repo.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      // Supabase returns user but session is null until email is verified
      if (response.session == null) {
        state = AuthAwaitingVerification(email);
      } else {
        state = AuthSuccess(response.user!);
      }
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = AuthLoading();
    try {
      final response = await _repo.signIn(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw Exception('Login failed. Please try again.');
      state = AuthSuccess(user);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // ── Resend verification email ────────────────────────────────────────────
  Future<void> resendVerification({required String email}) async {
    try {
      await _repo.resendVerificationEmail(email: email);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // ── Send OTP ─────────────────────────────────────────────────────────────
  Future<void> sendOtp({required String phone}) async {
    state = AuthLoading();
    try {
      await _repo.sendOtp(phone: phone);
      state = AuthInitial();
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // ── Verify OTP ───────────────────────────────────────────────────────────
  Future<void> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    state = AuthLoading();
    try {
      final response = await _repo.verifyOtp(phone: phone, otp: otp);
      final user = response.user;
      if (user == null) throw Exception('Verification failed. Try again.');
      state = AuthSuccess(user);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _repo.signOut();
    state = AuthInitial();
  }

  void reset() => state = AuthInitial();
}

// ── Provider ───────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});