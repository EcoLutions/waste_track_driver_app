import 'package:waste_track_driver_app/entities/route/api/dto/create_route_request.dart';
import 'package:waste_track_driver_app/entities/route/api/dto/route_response.dart';
import 'package:waste_track_driver_app/entities/route/api/dto/update_route_request.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class RouteService {
  Future<Resource<RouteResponse>> getById(String id);
  Future<Resource<List<RouteResponse>>> getAll({
    String? districtId,
    String? driverId,
    String? vehicleId,
    String? status,
    List<String>? statuses,
  });
  Future<Resource<List<RouteResponse>>> getActiveByDistrictId(String districtId);
  Future<Resource<RouteResponse>> create(CreateRouteRequest request);
  Future<Resource<RouteResponse>> update(String id, UpdateRouteRequest request);
  Future<Resource<void>> delete(String id);
  Future<Resource<RouteResponse>> generateOptimizedWaypoints(String id);
  Future<Resource<RouteResponse>> startRoute(String routeId);
  Future<Resource<RouteResponse>> completeRoute(String routeId);
  Future<Resource<void>> updateDriverLocation(String routeId, double latitude, double longitude);
  Future<Resource<RouteResponse>> markWaypointAsVisited(String routeId, String waypointId);
}
