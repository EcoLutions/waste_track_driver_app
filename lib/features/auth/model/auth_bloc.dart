import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/features/auth/api/auth_repository.dart';
import 'package:waste_track_driver_app/features/auth/model/auth_event.dart';
import 'package:waste_track_driver_app/features/auth/model/auth_state.dart';
import 'package:waste_track_driver_app/features/auth/model/sign_in_request.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.initial()) {
    on<SignInRequested>(_onSignInRequested);
    on<TokenValidationRequested>(_onTokenValidationRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  final AuthRepository _authRepository;
  final Logger _logger = Logger();

  // ==================== SIGN IN ====================

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit,) async {
    _logger.i('SignIn requested for email: ${event.email}');
    emit(const AuthState.authenticating());

    final request = SignInRequest(
      email: event.email,
      password: event.password,
    );

    final result = await _authRepository.signIn(request);

    switch (result) {
      case Success(data: final user):
        _logger.i('SignIn successful for user: ${user.email}');
        emit(AuthState.authenticated(user));
        break;

      case Failure(message: final msg):
        _logger.e('SignIn failed: $msg');
        emit(AuthState.error(msg));
        await Future.delayed(const Duration(seconds: 3));
        emit(AuthState.unauthenticated(message: msg));
        break;
    }
  }

  // ==================== TOKEN VALIDATION ====================

  Future<void> _onTokenValidationRequested(TokenValidationRequested event, Emitter<AuthState> emit,) async {
    _logger.i('Token validation requested');
    emit(const AuthState.validating());

    await Future.delayed(const Duration(seconds: 1));

    final hasToken = await _authRepository.hasToken();
    if (!hasToken) {
      _logger.i('No token found');
      emit(const AuthState.unauthenticated());
      return;
    }

    final result = await _authRepository.validateToken();

    switch (result) {
      case Success(data: final user):
        _logger.i('Token valid for user: ${user.email}');
        emit(AuthState.authenticated(user));
        break;

      case Failure(message: final msg):
        _logger.e('Token validation failed: $msg');
        emit(AuthState.unauthenticated(message: msg));
        break;
    }
  }

  // ==================== LOGOUT ====================

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit,) async {
    _logger.i('Logout requested');
    await _authRepository.logout();
    emit(const AuthState.unauthenticated(message: 'Sesión cerrada'));
  }
}