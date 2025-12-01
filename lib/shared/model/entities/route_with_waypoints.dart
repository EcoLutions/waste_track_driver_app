import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';
import 'package:waste_track_driver_app/shared/model/entities/waypoint_with_container.dart';

class RouteWithWaypoints {
  RouteWithWaypoints({
    required this.route,
    required this.waypointsWithContainers,
  });
  final Route route;
  final List<WaypointWithContainer> waypointsWithContainers;
}