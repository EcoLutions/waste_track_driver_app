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
  Future<Resource<RouteAssignmentData>> loadActiveRouteForDriver({
    required String driverId,
    required String districtId,
  }) async {
    _logger.i('🔍 Loading active route for driver: $driverId in district: $districtId');

    final routesResult = await _routeRepository.getActiveByDistrictId(districtId);

    switch (routesResult) {
      case Success(data: final routes):
        _logger.i('📋 Found ${routes.length} active routes in district');

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
  Future<Resource<RouteAssignmentData>> refreshRoute(String routeId) async {
    _logger.i('🔄 Refreshing route: $routeId');
    return _loadRouteData(routeId);
  }

  @override
  Future<Resource<RouteAssignmentData>> generateOptimizedWaypoints(String routeId) async {
    _logger.i('🗺️ Generating optimized waypoints for route: $routeId');

    final result = await _routeRepository.generateOptimizedWaypoints(routeId);

    switch (result) {
      case Success():
        _logger.i('✅ Waypoints generated, reloading route data');
        return _loadRouteData(routeId);

      case Failure(message: final msg, statusCode: final code):
        _logger.e('❌ Failed to generate waypoints: $msg');
        return Failure(message: msg, statusCode: code);
    }
  }

  @override
  Future<Resource<RouteAssignmentData>> markWaypointAsVisited(String waypointId, String routeId) async {
    _logger.i('✅ Marking waypoint as visited: $waypointId');

    final result = await _wayPointRepository.markAsVisited(waypointId, routeId);

    switch (result) {
      case Success():
        _logger.i('✅ Waypoint marked as visited, reloading route data');
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
        _logger.i('📊 Route status: ${route.status.displayName}');

        // Paso 2: Cargar WayPoints
        final wayPointsResult = await _wayPointRepository.getByRouteId(routeId);

        switch (wayPointsResult) {
          case Success(data: final wayPoints):
            _logger.i('📍 Found ${wayPoints.length} waypoints');

            if (wayPoints.isEmpty) {
              _logger.i('ℹ️ Route has no waypoints yet - returning route with empty waypoints list');
              return Success(RouteAssignmentData(
                route: route,
                wayPointsWithContainers: [],
              ));
            }

            // Ordenar por sequenceOrder
            wayPoints.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

            // Paso 3: Cargar Containers para cada waypoint
            final wayPointsWithContainers = <WayPointWithContainer>[];

            for (final wayPoint in wayPoints) {
              final containerResult = await _containerRepository.getById(wayPoint.containerId);

              switch (containerResult) {
                case Success(data: final container):
                  wayPointsWithContainers.add(WayPointWithContainer(
                    wayPoint: wayPoint,
                    container: container,
                  ));
                  break;

                case Failure(message: final msg):
                  _logger.w('⚠️ Failed to load container ${wayPoint.containerId}: $msg');
                  // Continuar con los demás waypoints
                  break;
              }
            }

            // ✅ Solo fallar si hay waypoints pero NINGUNO tiene container
            if (wayPoints.isNotEmpty && wayPointsWithContainers.isEmpty) {
              _logger.w('⚠️ No waypoints with containers could be loaded');
              return const Failure(
                message: 'No se pudieron cargar los contenedores de los puntos de recolección',
                statusCode: 500,
              );
            }

            _logger.i('✅ Route data loaded: ${wayPointsWithContainers.length} waypoints with containers');

            return Success(RouteAssignmentData(
              route: route,
              wayPointsWithContainers: wayPointsWithContainers,
            ));

          case Failure(message: final msg, statusCode: final code):
            if (code == 404 || msg.contains('not found') || msg.contains('No se encontraron')) {
              _logger.i('ℹ️ No waypoints found for route - returning route with empty waypoints list');
              return Success(RouteAssignmentData(
                route: route,
                wayPointsWithContainers: [],
              ));
            }

            _logger.e('❌ Failed to load waypoints: $msg');
            return Failure(message: msg, statusCode: code);
        }

      case Failure(message: final msg, statusCode: final code):
        _logger.e('❌ Failed to load route: $msg');
        return Failure(message: msg, statusCode: code);
    }
  }
}