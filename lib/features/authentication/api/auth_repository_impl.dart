import 'package:waste_track_driver_app/entities/user/api/mappers/user_mapper.dart';
import 'package:waste_track_driver_app/entities/user/api/user_service.dart';
import 'package:waste_track_driver_app/entities/user/model/user.dart';
import 'package:waste_track_driver_app/features/authentication/api/auth_repository.dart';
import 'package:waste_track_driver_app/features/authentication/api/auth_service.dart';
import 'package:waste_track_driver_app/features/authentication/model/auth_basic_data.dart';
import 'package:waste_track_driver_app/features/authentication/model/sign_in_request.dart';
import 'package:waste_track_driver_app/shared/lib/storage/secure_storage_service.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthService authService,
    required UserService userService,
    required SecureStorageService secureStorage,
  })  : _authService = authService,
        _userService = userService,
        _secureStorage = secureStorage;

  final AuthService _authService;
  final UserService _userService;
  final SecureStorageService _secureStorage;

  @override
  Future<Resource<AuthBasicData>> signIn(SignInRequest request) async {
    if (request.email == null || request.email!.isEmpty) {
      return const Failure(message: 'Email es requerido');
    }
    if (request.password == null || request.password!.isEmpty) {
      return const Failure(message: 'Contraseña es requerida');
    }

    // Paso 1: Llamar al servicio de autenticación
    final signInResult = await _authService.signIn(request);

    switch (signInResult) {
      case Success(data: final authResponse):
      // Paso 2: Guardar token
        if (authResponse.token == null) {
          return const Failure(message: 'Token no recibido del servidor');
        }

        await _secureStorage.saveToken(authResponse.token!);

        // Paso 3: Obtener información básica del usuario
        final userResult = await _userService.getCurrentUser();

        switch (userResult) {
          case Success(data: final userDto):
            final user = userDto.toDomain();

            // Paso 4: Validar que el usuario puede acceder
            final validationResult = _validateUserAccess(user);
            if (validationResult is Failure) {
              await _secureStorage.deleteToken();
              return Failure(message: validationResult.message);
            }

            // Paso 5: Retornar datos básicos de autenticación
            return Success(AuthBasicData(
              userId: user.id,
              token: authResponse.token!,
              roles: user.roles,
            ));

          case Failure(message: final msg, statusCode: final code):
            await _secureStorage.deleteToken();
            return Failure(message: msg, statusCode: code);
        }

      case Failure(message: final msg, statusCode: final code):
        return Failure(message: msg, statusCode: code);
    }
  }

  @override
  Future<Resource<String>> forgotPassword(String email) async {
    if (email.isEmpty) {
      return const Failure(message: 'Email es requerido');
    }

    final result = await _authService.forgotPassword(email);

    switch (result) {
      case Success():
        return const Success('Se ha enviado un correo con instrucciones para recuperar tu contraseña.',);
      case Failure(message: final msg, statusCode: final code):
        return Failure(message: msg, statusCode: code);
    }
  }

  @override
  Future<Resource<AuthBasicData>> validateToken() async {
    final hasToken = await _secureStorage.hasToken();
    if (!hasToken) {
      return const Failure(message: 'No hay sesión activa');
    }

    // Obtener información del usuario con el token actual
    final userResult = await _userService.getCurrentUser();

    switch (userResult) {
      case Success(data: final userDto):
        final user = userDto.toDomain();

        // Validar que el usuario puede acceder
        final validationResult = _validateUserAccess(user);
        if (validationResult is Failure) {
          await _secureStorage.deleteToken();
          return Failure(message: validationResult.message);
        }

        // Obtener el token guardado
        final token = await _secureStorage.getToken();
        if (token == null) {
          return const Failure(message: 'Token no encontrado');
        }

        return Success(AuthBasicData(
          userId: user.id,
          token: token,
          roles: user.roles,
        ));

      case Failure(message: final msg, statusCode: final code):
        await _secureStorage.deleteToken();
        return Failure(message: msg, statusCode: code);
    }
  }

  @override
  Future<bool> hasToken() async {
    return _secureStorage.hasToken();
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }

  Resource<void> _validateUserAccess(User user) {
    // Validar rol de conductor
    if (!user.canAccessDriverApp) {
      return const Failure(
        message: 'Esta aplicación es solo para conductores. '
            'Tu rol no tiene acceso.',
      );
    }

    // Validar estado de la cuenta
    if (!user.canLogin) {
      return Failure(
        message: 'Tu cuenta está ${user.status.displayName}. '
            'Contacta al administrador.',
      );
    }

    return const Success(null);
  }
}