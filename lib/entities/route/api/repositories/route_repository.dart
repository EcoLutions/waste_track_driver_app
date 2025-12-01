import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class RouteRepository {
  Future<Resource<Route>> getById(String id);
  Future<Resource<List<Route>>> getAll({
    String? districtId,
    String? driverId,
    String? vehicleId,
    String? status,
    List<String>? statuses,
  });
  Future<Resource<List<Route>>> getActiveByDistrictId(String districtId);
  Future<Resource<Route>> create(Route route);
  Future<Resource<Route>> update(Route route);
  Future<Resource<void>> delete(String id);
  Future<Resource<Route>> startRoute(String routeId);
  Future<Resource<Route>> generateOptimizedWaypoints(String id);
  Future<Resource<void>> updateDriverLocation(String routeId, double latitude, double longitude);
}
