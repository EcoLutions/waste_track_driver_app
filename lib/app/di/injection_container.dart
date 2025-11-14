import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_repository.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_repository_impl.dart';
import 'package:waste_track_driver_app/entities/district/district.dart';
import 'package:waste_track_driver_app/entities/user/user.dart';
import 'package:waste_track_driver_app/entities/user_profile/user_profile.dart';
import 'package:waste_track_driver_app/features/authentication/api/auth_service_imp.dart';
import 'package:waste_track_driver_app/features/authentication/authentication.dart';
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

  // Dio Client (with interceptor JWT)
  sl.registerLazySingleton<DioClient>(
        () => DioClient(sl<SecureStorageService>()),
  );

  // ==================== ENTITIES - USER ====================

  // User Service
  sl.registerLazySingleton<UserService>(
        () => UserServiceImpl(sl<DioClient>()),
  );

  // ==================== ENTITIES - USER PROFILE ====================

  // UserProfile Service
  sl.registerLazySingleton<UserProfileService>(
        () => UserProfileServiceImpl(sl<DioClient>()),
  );

  // ==================== ENTITIES - DISTRICT ====================

  // District Service
  sl.registerLazySingleton<DistrictService>(
        () => DistrictServiceImpl(sl<DioClient>()),
  );

// ==================== APP BLOCS ====================
// AuthBloc (global)
  sl.registerFactory<AuthBloc>(
        () => AuthBloc(authRepository: sl()),
  );

// UserSessionBloc (global)
  sl.registerFactory<UserSessionBloc>(
        () => UserSessionBloc(userSessionRepository: sl()),
  );

// ==================== REPOSITORIES ====================
// AuthRepository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      authService: sl(),
      userService: sl(),
      secureStorage: sl(),
    ),
  );

// UserSessionRepository
  sl.registerLazySingleton<UserSessionRepository>(
        () => UserSessionRepositoryImpl(
      userService: sl(),
      userProfileService: sl(),
      districtService: sl(),
    ),
  );

// ==================== SERVICES ====================
// AuthService
  sl.registerLazySingleton<AuthService>(
        () => AuthServiceImpl(sl()),
  );
}