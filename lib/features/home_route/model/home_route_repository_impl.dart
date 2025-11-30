import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/entities/route/api/repositories/route_repository.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/repositories/waypoint_repository.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_repository.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class HomeRouteRepositoryImpl implements HomeRouteRepository {
  HomeRouteRepositoryImpl({
    required RouteRepository routeRepository,
    required WayPointRepository wayPointRepository,
  })  : _routeRepository = routeRepository,
        _wayPointRepository = wayPointRepository;

  final RouteRepository _routeRepository;
  final WayPointRepository _wayPointRepository;
  final Logger _logger = Logger();

  @override
  Future<Resource<Route?>> getActiveRouteForDriver({
    required String driverId,
    required String districtId,
  }) async {
    _logger.i('🏠 [HomeRoute] Loading active route for driver: $driverId in district: $districtId');

    final routesResult = await _routeRepository.getAll(driverId: driverId, districtId: districtId, status: 'ACTIVE',);

    switch (routesResult) {
      case Success(data: final routes):
        _logger.i('📋 [HomeRoute] Found ${routes.length} active routes');

        // Si no hay rutas, es un estado válido (Success con null)
        if (routes.isEmpty) {
          _logger.i('ℹ️ [HomeRoute] No active routes found - OK');
          return const Success(null);
        }

        final activeRoute = routes.first;
        _logger.i('✅ [HomeRoute] Active route found: ${activeRoute.id}');

        // Paso 2: Verificar si tiene waypoints (para saber si ya fue optimizada)
        final wayPointsResult = await _wayPointRepository.getByRouteId(activeRoute.id);

        switch (wayPointsResult) {
          case Success(data: final wayPoints):
            final hasWaypoints = wayPoints.isNotEmpty;
            _logger.i('📍 [HomeRoute] Route has ${wayPoints.length} waypoints (hasWaypoints: $hasWaypoints)');

            // Retornamos la ruta (el estado del BLoC decidirá qué mostrar)
            return Success(activeRoute);

          case Failure(statusCode: 404):
          // 404 en waypoints = ruta existe pero sin waypoints (OK)
            _logger.i('ℹ️ [HomeRoute] Route exists but no waypoints yet');
            return Success(activeRoute);

          case Failure(message: final msg, statusCode: final code):
          // Error al cargar waypoints
            _logger.e('❌ [HomeRoute] Error loading waypoints: $msg');
            return Failure(message: msg, statusCode: code);
        }

      case Failure(message: final msg, statusCode: final code):
        _logger.e('❌ [HomeRoute] Error loading routes: $msg');
        return Failure(message: msg, statusCode: code);
    }
  }
}