import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/user/model/user_role.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;

  const factory AuthState.validating() = AuthValidating;

  const factory AuthState.authenticating() = AuthAuthenticating;
  
  const factory AuthState.authenticated({
    required String userId,
    required String token,
    required List<UserRole> roles,
  }) = AuthAuthenticated;

  const factory AuthState.unauthenticated({String? message}) = AuthUnauthenticated;

  const factory AuthState.error(String message) = AuthError;

  const factory AuthState.forgotPasswordSuccess({String? message}) = AuthForgotPasswordSuccess;
}

extension AuthStateX on AuthState {
  bool get isAuthenticated => this is AuthAuthenticated;

  bool get isLoading => this is AuthValidating || this is AuthAuthenticating;

  String? get userId => switch (this) {
    AuthAuthenticated(userId: final id) => id,
    _ => null,
  };

  List<UserRole>? get roles => switch (this) {
    AuthAuthenticated(roles: final r) => r,
    _ => null,
  };

  bool get canAccessDriverApp => switch (this) {
    AuthAuthenticated(roles: final r) => r.any((role) => role.canAccessDriverApp),
    _ => false,
  };
}