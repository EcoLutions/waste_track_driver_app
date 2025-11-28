import 'package:waste_track_driver_app/entities/waypoint/model/entities/waypoint.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class WayPointRepository {
  Future<Resource<WayPoint>> getById(String id);
  Future<Resource<List<WayPoint>>> getAll({String? routeId});
  Future<Resource<List<WayPoint>>> getByRouteId(String routeId);
  Future<Resource<WayPoint>> create(WayPoint waypoint, String routeId);
  Future<Resource<WayPoint>> update(WayPoint waypoint);
  Future<Resource<void>> delete(String id);
  Future<Resource<WayPoint>> markAsVisited(String id, String routeId);
}
