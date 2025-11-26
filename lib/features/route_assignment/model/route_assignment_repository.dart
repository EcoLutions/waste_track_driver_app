import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_data.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class RouteAssignmentRepository {
  Future<Resource<RouteAssignmentData>> loadActiveRouteForDriver({
    required String driverId,
    required String districtId,
  });
  Future<Resource<RouteAssignmentData>> refreshRoute(String routeId);
  Future<Resource<RouteAssignmentData>> generateOptimizedWaypoints(String routeId);
}