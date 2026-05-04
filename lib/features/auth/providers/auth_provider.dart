// lib/features/auth/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_auth_state.dart';
import '../data/auth_repository.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/supabase/supabase_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(AppAuthInitial());

  // ── Email signup ──────────────────────────────────────────────────────────
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required int age,
  }) async {
    state = AppAuthLoading();
    try {
      final res = await _repo.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
        age: age,
      );
      if (res.user != null) {
        if (res.user!.emailConfirmedAt != null) {
          state = AppAuthSuccess(res.user!);
          await FcmService.instance.onUserLoggedIn();
        } else {
          state = AppAuthAwaitingVerification(email);
        }
      } else {
        state = AppAuthError('Signup failed. Please try again.');
      }
    } catch (e) {
      state = AppAuthError(_parseError(e));
    }
  }

  // ── Email login ───────────────────────────────────────────────────────────
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = AppAuthLoading();
    try {
      final res = await _repo.signInWithEmail(email: email, password: password);
      if (res.user != null) {
        state = AppAuthSuccess(res.user!);
        await FcmService.instance.onUserLoggedIn();
      } else {
        state = AppAuthError('Login failed. Please try again.');
      }
    } catch (e) {
      final msg = _parseError(e);
      if (msg.toLowerCase().contains('email not confirmed')) {
        state = AppAuthAwaitingVerification(email);
      } else {
        state = AppAuthError(msg);
      }
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    state = AppAuthLoading();
    try {
      final result = await _repo.signInWithGoogle();
      final user   = result.response.user;

      if (user == null) {
        state = AppAuthError('Google sign-in failed. Please try again.');
        return;
      }

      await FcmService.instance.onUserLoggedIn();

      if (result.isNewUser) {
        // New user → setup screen with prefilled Google data
        state = AppAuthNewGoogleUser(
          user,
          result.displayName,
          result.photoUrl,
        );
      } else {
        // Returning user → straight to home
        state = AppAuthSuccess(user);
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('cancelled') || msg.contains('cancel')) {
        state = AppAuthInitial();
      } else {
        state = AppAuthError(_parseError(e));
      }
    }
  }

  // ── Phone ─────────────────────────────────────────────────────────────────
  Future<void> signInWithPhone(String phone) async {
    state = AppAuthLoading();
    try {
      await _repo.signInWithPhone(phone);
      state = AppAuthAwaitingVerification(phone);
    } catch (e) {
      state = AppAuthError(_parseError(e));
    }
  }

  Future<void> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    state = AppAuthLoading();
    try {
      final res = await _repo.verifyPhoneOtp(phone: phone, token: token);
      if (res.user != null) {
        state = AppAuthSuccess(res.user!);
        await FcmService.instance.onUserLoggedIn();
      } else {
        state = AppAuthError('Invalid OTP. Please try again.');
      }
    } catch (e) {
      state = AppAuthError(_parseError(e));
    }
  }

  // ── Email verification check ──────────────────────────────────────────────
  Future<bool> checkEmailVerified() async {
    try {
      final res = await supabase.auth.refreshSession();
      if (res.user != null && res.user!.emailConfirmedAt != null) {
        state = AppAuthSuccess(res.user!);
        await FcmService.instance.onUserLoggedIn();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> resendEmailVerification(String email) async {
    try {
      await _repo.resendEmailVerification(email);
    } catch (e) {
      state = AppAuthError(_parseError(e));
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = AppAuthInitial();
  }

  void reset() => state = AppAuthInitial();

  String _parseError(dynamic e) {
    if (e is AuthException) return e.message;
    return e.toString().replaceAll('Exception: ', '');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
