import 'package:waste_track_driver_app/entities/container/model/entities/container.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/entities/waypoint.dart';

class WaypointWithContainer {
  WaypointWithContainer({
    required this.waypoint,
    required this.container,
    required this.address,
  });
  final WayPoint waypoint;
  final Container container;
  final String address;
}