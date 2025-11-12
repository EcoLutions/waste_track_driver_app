import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_track_driver_app/entities/user/user.dart';
import 'package:waste_track_driver_app/features/auth/api/auth_repository.dart';
import 'package:waste_track_driver_app/features/auth/api/auth_repository_impl.dart';
import 'package:waste_track_driver_app/features/auth/api/auth_service.dart';
import 'package:waste_track_driver_app/features/auth/api/auth_service_imp.dart';
import 'package:waste_track_driver_app/features/auth/auth.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/storage/local_storage_service.dart';
import 'package:waste_track_driver_app/shared/lib/storage/secure_storage_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================== CORE - STORAGE ====================

  // Flutter Secure Storage
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  sl.registerLazySingleton(() => secureStorage);

  // Secure Storage Service
  sl.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService(sl()),
  );

  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Local Storage Service
  sl.registerLazySingleton<LocalStorageService>(
        () => LocalStorageService(sl()),
  );

  // ==================== SHARED - API ====================

  // Dio Client (con interceptor JWT)
  sl.registerLazySingleton<DioClient>(
        () => DioClient(sl<SecureStorageService>()),
  );

  // ==================== ENTITIES - USER ====================

  // User Service
  sl.registerLazySingleton<UserService>(
        () => UserServiceImpl(sl<DioClient>()),
  );

  // ==================== FEATURES - AUTH ====================

  // Auth Service
  sl.registerLazySingleton<AuthService>(
        () => AuthServiceImpl(sl<DioClient>()),
  );

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      authService: sl<AuthService>(),
      userService: sl<UserService>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // Auth Bloc (Factory - nueva instancia cada vez)
  sl.registerFactory<AuthBloc>(
        () => AuthBloc(authRepository: sl<AuthRepository>()),
  );
}