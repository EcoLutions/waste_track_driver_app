import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/entities/container/api/repositories/container_repository.dart';
import 'package:waste_track_driver_app/entities/route/api/repositories/route_repository.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/repositories/waypoint_repository.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_data.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_repository.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class RouteAssignmentRepositoryImpl implements RouteAssignmentRepository {
  RouteAssignmentRepositoryImpl({
    required RouteRepository routeRepository,
    required WayPointRepository wayPointRepository,
    required ContainerRepository containerRepository,
  })  : _routeRepository = routeRepository,
        _wayPointRepository = wayPointRepository,
        _containerRepository = containerRepository;

  final RouteRepository _routeRepository;
  final WayPointRepository _wayPointRepository;
  final ContainerRepository _containerRepository;
  final Logger _logger = Logger();

  @override
  Future<Resource<RouteAssignmentData>> loadActiveRouteForDriver({required String driverId, required String districtId,}) async {
    _logger.i('🔍 Loading active route for driver: $driverId in district: $districtId');

    final routesResult = await _routeRepository.getActiveByDistrictId(districtId);

    switch (routesResult) {
      case Success(data: final routes):
        _logger.i('📋 Found ${routes.length} active routes in district');

        // Filtrar por el driverId específico
        try {
          final activeRoute = routes.firstWhere(
                (route) => route.driverId == driverId,
          );

          _logger.i('✅ Found active route for driver: ${activeRoute.id}');
          return _loadRouteData(activeRoute.id);

        } catch (e) {
          _logger.i('ℹ️ No active route found for driver $driverId in district $districtId');
          return const Failure(
            message: 'No active route found',
            statusCode: 404,
          );
        }

      case Failure(message: final msg, statusCode: final code):
        _logger.e('❌ Failed to load routes: $msg');
        return Failure(message: msg, statusCode: code);
    }
  }

  @override
  Future<Resource<RouteAssignmentData>> markWaypointAsVisited(String waypointId, String routeId) async {
    _logger.i('✅ Marking waypoint as visited: $waypointId');

    final result = await _routeRepository.markWaypointAsVisited(routeId, waypointId);

    switch (result) {
      case Success():
        _logger.i('✅ Waypoint marked as visited, reloading route data');
        // Recargar todos los datos para reflejar el cambio
        return _loadRouteData(routeId);

      case Failure(message: final msg, statusCode: final code):
        _logger.e('❌ Failed to mark waypoint as visited: $msg');
        return Failure(message: msg, statusCode: code);
    }
  }

  Future<Resource<RouteAssignmentData>> _loadRouteData(String routeId) async {
    _logger.i('📦 Loading route data for: $routeId');

    // Paso 1: Cargar Route
    final routeResult = await _routeRepository.getById(routeId);

    switch (routeResult) {
      case Success(data: final route):
        _logger.i('✅ Route loaded: ${route.id}');

        // Paso 2: Cargar WayPoints
        final wayPointsResult = await _wayPointRepository.getByRouteId(routeId);

        switch (wayPointsResult) {
          case Success(data: final wayPoints):
            _logger.i('📍 Found ${wayPoints.length} waypoints');

            // Ordenar por sequenceOrder
            wayPoints.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

            // Paso 3: Cargar Containers para cada waypoint
            final wayPointsWithContainers = <WayPointWithContainer>[];

            for (final wayPoint in wayPoints) {
              final containerResult =
              await _containerRepository.getById(wayPoint.containerId);

              switch (containerResult) {
                case Success(data: final container):
                  wayPointsWithContainers.add(WayPointWithContainer(
                    wayPoint: wayPoint,
                    container: container,
                  ));
                  break;

                case Failure(message: final msg):
                  _logger.w(
                    '⚠️ Failed to load container ${wayPoint.containerId}: $msg',
                  );
                  // Continuar con los demás waypoints
                  break;
              }
            }

            if (wayPointsWithContainers.isEmpty) {
              _logger.w('⚠️ No waypoints with containers loaded');
              return const Failure(
                message: 'No se pudieron cargar los puntos de recolección',
              );
            }

            _logger.i(
              '✅ Route data loaded: ${wayPointsWithContainers.length} waypoints',
            );

            return Success(RouteAssignmentData(
              route: route,
              wayPointsWithContainers: wayPointsWithContainers,
            ));

          case Failure(message: final msg, statusCode: final code):
            _logger.e('❌ Failed to load waypoints: $msg');
            return Failure(message: msg, statusCode: code);
        }

      case Failure(message: final msg, statusCode: final code):
        _logger.e('❌ Failed to load route: $msg');
        return Failure(message: msg, statusCode: code);
    }
  }

  @override
  Future<Resource<void>> updateDriverLocation(String routeId, double latitude, double longitude) async {
    _logger.i('📍 Updating driver location for route: $routeId');

    final result = await _routeRepository.updateDriverLocation(routeId, latitude, longitude);

    switch (result) {
      case Success():
        _logger.i('Driver location updated');
        return const Success(null);
      case Failure<void>():
        _logger.e('Failed to update driver location');
        return const Failure(message: 'Error al actualizar la ubicación del conductor');
    }
  }

  @override
  Future<Resource<void>> completeRoute(String routeId) {
    _logger.i('🏁 Completing route: $routeId');

    return _routeRepository.completeRoute(routeId);
  }
}