// lib/features/auth/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_auth_state.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(AppAuthInitial());

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = AppAuthLoading();
    try {
      final res = await _repo.signUpWithEmail(email: email, password: password);
      if (res.user != null) {
        if (res.user!.emailConfirmedAt == null) {
          state = AppAuthAwaitingVerification(email);
        } else {
          state = AppAuthSuccess(res.user!);
        }
      } else {
        state = AppAuthError('Signup failed. Please try again.');
      }
    } catch (e) {
      state = AppAuthError(_parseError(e));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = AppAuthLoading();
    try {
      final res = await _repo.signInWithEmail(email: email, password: password);
      if (res.user != null) {
        state = AppAuthSuccess(res.user!);
      } else {
        state = AppAuthError('Login failed. Please try again.');
      }
    } catch (e) {
      state = AppAuthError(_parseError(e));
    }
  }

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
      } else {
        state = AppAuthError('Invalid OTP. Please try again.');
      }
    } catch (e) {
      state = AppAuthError(_parseError(e));
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