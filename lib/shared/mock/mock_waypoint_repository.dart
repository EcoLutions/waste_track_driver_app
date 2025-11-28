import 'package:waste_track_driver_app/entities/waypoint/api/repositories/waypoint_repository.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/entities/waypoint.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';
import 'package:waste_track_driver_app/shared/mock/mock_route_repository.dart';

class MockWayPointRepository implements WayPointRepository {
  final MockRouteRepository _routeRepository;

  MockWayPointRepository(this._routeRepository);

  @override
  Future<Resource<WayPoint>> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Buscar en todos los datos de ruta
    for (final routeData in _getAllRouteData()) {
      try {
        final waypoint = routeData.waypointsWithContainers
            .map((w) => w.waypoint)
            .firstWhere((w) => w.id == id);
        return Success(waypoint);
      } catch (e) {
        continue;
      }
    }

    return const Failure(
      message: 'Waypoint not found',
      statusCode: 404,
    );
  }

  @override
  Future<Resource<List<WayPoint>>> getAll({String? routeId}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (routeId != null) {
      return getByRouteId(routeId);
    }

    final allWaypoints = <WayPoint>[];
    for (final routeData in _getAllRouteData()) {
      allWaypoints.addAll(
        routeData.waypointsWithContainers.map((w) => w.waypoint),
      );
    }

    return Success(allWaypoints);
  }

  @override
  Future<Resource<List<WayPoint>>> getByRouteId(String routeId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final routeData = _routeRepository.getRouteData(routeId);
    if (routeData == null) {
      return const Failure(
        message: 'Route not found',
        statusCode: 404,
      );
    }

    final waypoints = routeData.waypointsWithContainers
        .map((w) => w.waypoint)
        .toList();

    return Success(waypoints);
  }

  @override
  Future<Resource<WayPoint>> create(WayPoint waypoint, String routeId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Success(waypoint);
  }

  @override
  Future<Resource<WayPoint>> update(WayPoint waypoint) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Success(waypoint);
  }

  @override
  Future<Resource<void>> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const Success(null);
  }

  @override
  Future<Resource<WayPoint>> markAsVisited(String id, String routeId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Buscar el waypoint y retornarlo (en mock no modificamos realmente el estado)
    final result = await getById(id);
    return result;
  }

  List<dynamic> _getAllRouteData() {
    return _routeRepository.getAllRouteData();
  }
}
