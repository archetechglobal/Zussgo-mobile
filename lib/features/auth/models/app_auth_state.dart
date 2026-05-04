import 'package:supabase_flutter/supabase_flutter.dart';

sealed class AppAuthState {}

class AppAuthInitial extends AppAuthState {}

class AppAuthLoading extends AppAuthState {}

class AppAuthSuccess extends AppAuthState {
  final User user;
  AppAuthSuccess(this.user);
}

class AppAuthAwaitingVerification extends AppAuthState {
  final String email;
  AppAuthAwaitingVerification(this.email);
}

class AppAuthError extends AppAuthState {
  final String message;
  AppAuthError(this.message);
}

/// Fired only when a brand-new Google user signs up.
/// Carries name + photo so the setup screen can prefill.
class AppAuthNewGoogleUser extends AppAuthState {
  final User user;
  final String displayName;
  final String photoUrl;
  const AppAuthNewGoogleUser(this.user, this.displayName, this.photoUrl);
}
