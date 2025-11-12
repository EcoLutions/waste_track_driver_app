import 'package:waste_track_driver_app/entities/user/user.dart';
import 'package:waste_track_driver_app/features/auth/api/auth_repository.dart';
import 'package:waste_track_driver_app/features/auth/api/auth_service.dart';
import 'package:waste_track_driver_app/features/auth/model/sign_in_request.dart';
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
  Future<Resource<User>> signIn(SignInRequest request) async {
    final signInResult = await _authService.signIn(request);

    return switch (signInResult) {
      Success(data: final authResponse) => await _handleSuccessfulSignIn(
        authResponse.token,
      ),
      Failure(message: final msg, statusCode: final code) => Failure(
        message: msg,
        statusCode: code,
      ),
    };
  }

  Future<Resource<User>> _handleSuccessfulSignIn(String token) async {
    await _secureStorage.saveToken(token);

    final userResult = await _userService.getCurrentUser();

    return switch (userResult) {
      Success(data: final user) => _validateUserRole(user),
      Failure(message: final msg, statusCode: final code) => Failure(
        message: msg,
        statusCode: code,
      ),
    };
  }

  Resource<User> _validateUserRole(User user) {
    if (!user.canAccessDriverApp) {
      return const Failure(
        message: 'Esta aplicación es solo para conductores. '
            'Tu rol no tiene acceso.',
      );
    }

    if (!user.canLogin) {
      return Failure(
        message: 'Tu cuenta está ${user.status.displayName}. '
            'Contacta al administrador.',
      );
    }

    return Success(user);
  }

  @override
  Future<Resource<User>> validateToken() async {
    final hasToken = await _secureStorage.hasToken();
    if (!hasToken) {
      return const Failure(message: 'No hay sesión activa');
    }

    final userResult = await _userService.getCurrentUser();

    return switch (userResult) {
      Success(data: final user) => _validateUserRole(user),
      Failure(message: final msg, statusCode: final code) => Failure(
        message: msg,
        statusCode: code,
      ),
    };
  }

  @override
  Future<bool> hasToken() async {
    return _secureStorage.hasToken();
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }
}