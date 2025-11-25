import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/entities/container/api/repositories/container_repository.dart';
import 'package:waste_track_driver_app/entities/route/api/repositories/route_repository.dart';
import 'package:waste_track_driver_app/entities/route/model/enums/route_status.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/repositories/waypoint_repository.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_data.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_repository.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';
import 'package:waste_track_driver_app/shared/mock/mock_route_repository.dart';

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
  Future<Resource<RouteAssignmentData>> loadActiveRouteForDriver(
      String driverId,
      ) async {
    _logger.i('🔍 Loading active route for driver: $driverId');

    // ✅ NUEVO: Si estamos usando mock, asegurar que existen datos
    if (_routeRepository is MockRouteRepository) {
      (_routeRepository as MockRouteRepository).ensureRouteForDriver(driverId);
    }

    final routesResult = await _routeRepository.getAll();

    switch (routesResult) {
      case Success(data: final routes):
        _logger.i('📋 Found ${routes.length} total routes');

        // Debug: Imprimir todas las rutas
        for (final route in routes) {
          _logger.d('   Route ${route.id}: driver=${route.driverId}, status=${route.status}');
        }

        try {
          final activeRoute = routes.firstWhere(
                (route) =>
            route.driverId == driverId &&
                (route.status == RouteStatus.assigned ||
                    route.status == RouteStatus.inProgress),
          );

          _logger.i('✅ Found active route: ${activeRoute.id}');
          return _loadRouteData(activeRoute.id);

        } catch (e) {
          _logger.i('ℹ️ No active route found for driver $driverId');
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
}