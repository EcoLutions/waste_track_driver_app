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
  })  : _routeRepository = routeRepository;

  final RouteRepository _routeRepository;
  final Logger _logger = Logger();

  @override
  Future<Resource<Route?>> getActiveRouteForDriver({required String driverId, required String districtId,}) async {
    _logger.i('[HomeRoute] Loading active route for driver: $driverId in district: $districtId');

    final routesResult = await _routeRepository.getAll(driverId: driverId, districtId: districtId, statuses: ['ACTIVE', 'IN_PROGRESS'],);

    switch (routesResult) {
      case Success(data: final routes):
        _logger.i('[HomeRoute] Found ${routes.length} active routes');

        if (routes.isEmpty) {
          _logger.i('[HomeRoute] No active routes found - OK');
          return const Success(null);
        }

        final activeRoute = routes.first;
        _logger.i('[HomeRoute] Active route found: ${activeRoute.id}');

        return Success(activeRoute);

      case Failure(message: final msg, statusCode: final code):
        _logger.e('[HomeRoute] Error loading routes: $msg');
        return Failure(message: msg, statusCode: code);
    }
  }

  @override
  Future<Resource<Route?>> startRoute({required String routeId}) async {
    _logger.i('[HomeRoute] Starting route: $routeId');

    final result = await _routeRepository.startRoute(routeId);

    switch (result) {
      case Success(data: final route):
        _logger.i('[HomeRoute] Route started: ${route.id}');
        return Success(route);
      case Failure(message: final msg, statusCode: final code):
        _logger.e('[HomeRoute] Error starting route: $msg');
        return Failure(message: msg, statusCode: code);
    }
  }
}