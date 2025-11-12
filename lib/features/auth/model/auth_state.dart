import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/user/user.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.validating() = AuthValidating;
  const factory AuthState.authenticating() = AuthAuthenticating;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;
  const factory AuthState.unauthenticated({String? message}) = AuthUnauthenticated;
  const factory AuthState.error(String message) = AuthError;
}

extension AuthStateX on AuthState {
  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isLoading => this is AuthValidating || this is AuthAuthenticating;

  User? get user => switch (this) {
    AuthAuthenticated(user: final u) => u, _ => null,
  };
}