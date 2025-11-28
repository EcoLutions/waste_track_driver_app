import 'package:waste_track_driver_app/entities/waypoint/api/dto/create_waypoint_request.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/dto/update_waypoint_request.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/dto/waypoint_response.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class WayPointService {
  Future<Resource<WayPointResponse>> getById(String id);
  Future<Resource<List<WayPointResponse>>> getAll({String? routeId});
  Future<Resource<List<WayPointResponse>>> getByRouteId(String routeId);
  Future<Resource<WayPointResponse>> create(CreateWayPointRequest request, String routeId);
  Future<Resource<WayPointResponse>> update(String id, UpdateWayPointRequest request);
  Future<Resource<void>> delete(String id);
  Future<Resource<WayPointResponse>> markAsVisited(String id, String routeId);
}