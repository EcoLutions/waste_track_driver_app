import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_track_driver_app/app/bloc/auth/auth_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_bloc.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_repository.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_repository_impl.dart';
import 'package:waste_track_driver_app/entities/container/api/repositories/container_repository.dart';
import 'package:waste_track_driver_app/entities/container/api/repositories/container_repository_impl.dart';
import 'package:waste_track_driver_app/entities/container/api/services/container_service.dart';
import 'package:waste_track_driver_app/entities/container/api/services/container_service_impl.dart';
import 'package:waste_track_driver_app/entities/district/district.dart';
import 'package:waste_track_driver_app/entities/driver/api/repositories/driver_repository.dart';
import 'package:waste_track_driver_app/entities/driver/api/repositories/driver_repository_impl.dart';
import 'package:waste_track_driver_app/entities/driver/api/services/driver_service.dart';
import 'package:waste_track_driver_app/entities/driver/api/services/driver_service_impl.dart';
import 'package:waste_track_driver_app/entities/route/api/repositories/route_repository.dart';
import 'package:waste_track_driver_app/entities/route/api/repositories/route_repository_impl.dart';
import 'package:waste_track_driver_app/entities/route/api/services/route_service.dart';
import 'package:waste_track_driver_app/entities/route/api/services/route_service_impl.dart';
import 'package:waste_track_driver_app/entities/user/user.dart';
import 'package:waste_track_driver_app/entities/user_profile/user_profile.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/repositories/waypoint_repository.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/repositories/waypoint_repository_impl.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/services/waypoint_service.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/services/waypoint_service_impl.dart';
import 'package:waste_track_driver_app/features/authentication/api/auth_service_imp.dart';
import 'package:waste_track_driver_app/features/authentication/authentication.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_bloc.dart';  // ⭐ NUEVO
import 'package:waste_track_driver_app/features/home_route/model/home_route_repository.dart';  // ⭐ NUEVO
import 'package:waste_track_driver_app/features/home_route/model/home_route_repository_impl.dart';  // ⭐ NUEVO
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_bloc.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_repository.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_repository_impl.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/storage/local_storage_service.dart';
import 'package:waste_track_driver_app/shared/lib/storage/secure_storage_service.dart';
import 'package:waste_track_driver_app/shared/services/directions_service.dart';
import 'package:waste_track_driver_app/shared/services/location_service.dart';

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

  // ==================== ENTITIES - DRIVER ====================

  // Driver Service
  sl.registerLazySingleton<DriverService>(
        () => DriverServiceImpl(sl<DioClient>()),
  );

  // Driver Repository
  sl.registerLazySingleton<DriverRepository>(
        () => DriverRepositoryImpl(sl<DriverService>()),
  );

  // ==================== ENTITIES - ROUTE ====================

  // Route Service
  sl.registerLazySingleton<RouteService>(
        () => RouteServiceImpl(sl<DioClient>()),
  );

  // Route Repository
  sl.registerLazySingleton<RouteRepository>(
        () => RouteRepositoryImpl(sl<RouteService>()),
  );

  // ==================== ENTITIES - WAYPOINT ====================

  // WayPoint Service
  sl.registerLazySingleton<WayPointService>(
        () => WayPointServiceImpl(sl<DioClient>()),
  );

  // WayPoint Repository
  sl.registerLazySingleton<WayPointRepository>(
        () => WayPointRepositoryImpl(sl<WayPointService>()),
  );

  // ==================== ENTITIES - CONTAINER ====================

  // Container Service
  sl.registerLazySingleton<ContainerService>(
        () => ContainerServiceImpl(sl<DioClient>()),
  );

  // Container Repository
  sl.registerLazySingleton<ContainerRepository>(
        () => ContainerRepositoryImpl(sl<ContainerService>()),
  );

  // ==================== APP BLOCS ====================

  // AuthBloc (global)
  sl.registerFactory<AuthBloc>(
        () => AuthBloc(authRepository: sl()),
  );

  // UserSessionBloc (global)
  sl.registerFactory<UserSessionBloc>(
        () => UserSessionBloc(
      userSessionRepository: sl(),
      userProfileRepository: sl(),
      authRepository: sl(),
    ),
  );

  // RouteAssignmentBloc (for route-map page)
  sl.registerFactory<RouteAssignmentBloc>(
        () => RouteAssignmentBloc(routeAssignmentRepository: sl()),
  );

  // ⭐ HomeRouteBloc (for home page)
  sl.registerFactory<HomeRouteBloc>(
        () => HomeRouteBloc(homeRouteRepository: sl()),
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
      driverRepository: sl(),
    ),
  );

  // RouteAssignmentRepository
  sl.registerLazySingleton<RouteAssignmentRepository>(
        () => RouteAssignmentRepositoryImpl(
      routeRepository: sl(),
      wayPointRepository: sl(),
      containerRepository: sl(),
    ),
  );

  sl.registerLazySingleton<HomeRouteRepository>(
        () => HomeRouteRepositoryImpl(
      routeRepository: sl(),
      wayPointRepository: sl(),
    ),
  );

  // UserProfileRepository
  sl.registerLazySingleton<UserProfileRepository>(
        () => UserProfileRepositoryImpl(sl()),
  );

  // ==================== SERVICES ====================

  // AuthService
  sl.registerLazySingleton<AuthService>(
        () => AuthServiceImpl(sl()),
  );

  // LocationService
  sl.registerLazySingleton<LocationService>(
        () => LocationService(),
  );

  // DirectionsService
  sl.registerLazySingleton<DirectionsService>(
        () => DirectionsService(),
  );
}