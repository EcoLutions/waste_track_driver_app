import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_event.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_state.dart';
import 'package:waste_track_driver_app/features/authentication/api/auth_repository.dart';
import 'package:waste_track_driver_app/features/authentication/model/sign_in_request.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';
import 'package:waste_track_driver_app/shared/websocket/websocket_manager.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.initial()) {
    on<SignInRequested>(_onSignInRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<TokenValidationRequested>(_onTokenValidationRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpired>(_onSessionExpired);
  }

  final AuthRepository _authRepository;
  final Logger _logger = Logger();

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit,) async {
    _logger.i('SignIn requested for email: ${event.email}');
    emit(const AuthState.authenticating());

    final request = SignInRequest(
      email: event.email,
      password: event.password,
    );

    final result = await _authRepository.signIn(request);

    switch (result) {
      case Success(data: final authData):
        await WebSocketManager().connect();
        _logger.i('WebSocket connected');
        _logger.i('SignIn successful for user: ${authData.userId}');
        emit(AuthState.authenticated(
          userId: authData.userId,
          token: authData.token,
          roles: authData.roles,
        ));
        break;

      case Failure(message: final msg):
        _logger.e('SignIn failed: $msg');
        emit(AuthState.error(msg));
        await Future.delayed(const Duration(seconds: 3));
        emit(AuthState.unauthenticated(message: msg));
        break;
    }
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit,) async {
    _logger.i('Forgot password requested for email: ${event.email}');
    emit(const AuthState.authenticating());

    final result = await _authRepository.forgotPassword(event.email);

    switch (result) {
      case Success(data: final msg):
        _logger.i('Forgot password successful');
        emit(AuthState.forgotPasswordSuccess(message: msg));
        await Future.delayed(const Duration(seconds: 3));
        emit(const AuthState.unauthenticated());
        break;

      case Failure(message: final msg):
        _logger.e('Forgot password failed: $msg');
        emit(AuthState.error(msg));
        await Future.delayed(const Duration(seconds: 3));
        emit(AuthState.unauthenticated(message: msg));
        break;
    }
  }

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
      case Success(data: final authData):
        _logger.i('Token valid for user: ${authData.userId}');
        emit(AuthState.authenticated(
          userId: authData.userId,
          token: authData.token,
          roles: authData.roles,
        ));
        break;

      case Failure(message: final msg):
        _logger.e('Token validation failed: $msg');
        emit(AuthState.unauthenticated(message: msg));
        break;
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit,) async {
    WebSocketManager().disconnect();
    _logger.i('WebSocket disconnected');
    _logger.i('Logout requested');
    await _authRepository.logout();
    emit(const AuthState.unauthenticated(message: 'Sesión cerrada'));
  }

  Future<void> _onSessionExpired(SessionExpired event, Emitter<AuthState> emit,) async {
    _logger.w('Session expired');
    await _authRepository.logout();
    emit(const AuthState.unauthenticated(
      message: 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
    ));
  }
}