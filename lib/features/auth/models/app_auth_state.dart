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