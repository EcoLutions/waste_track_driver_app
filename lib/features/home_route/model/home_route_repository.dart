import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class HomeRouteRepository {
  Future<Resource<Route?>> getActiveRouteForDriver({
    required String driverId,
    required String districtId,
  });
}