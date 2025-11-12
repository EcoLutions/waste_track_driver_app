import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class SignInRequested extends AuthEvent {

  const SignInRequested({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class TokenValidationRequested extends AuthEvent {
  const TokenValidationRequested();
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}