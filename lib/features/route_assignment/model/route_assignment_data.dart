import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';

class RouteAssignmentData {
  const RouteAssignmentData({
    required this.route,
    required this.wayPointsWithContainers,
  });

  final Route route;
  final List<WayPointWithContainer> wayPointsWithContainers;

  int get totalWaypoints => wayPointsWithContainers.length;

  int get completedWaypoints =>
      wayPointsWithContainers.where((w) => w.isCompleted).length;

  int get pendingWaypoints =>
      wayPointsWithContainers.where((w) => w.isPending).length;

  double get completionPercentage {
    if (totalWaypoints == 0) return 0;
    return (completedWaypoints / totalWaypoints) * 100;
  }

  WayPointWithContainer? get nextWaypoint {
    try {
      return wayPointsWithContainers.firstWhere((w) => w.isPending);
    } catch (e) {
      return null;
    }
  }
}