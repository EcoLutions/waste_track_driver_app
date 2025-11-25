import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/container/model/entities/container.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/entities/waypoint.dart';

part 'route_assignment_state.freezed.dart';

@freezed
sealed class RouteAssignmentState with _$RouteAssignmentState {
  const factory RouteAssignmentState.initial() = RouteAssignmentInitial;
  const factory RouteAssignmentState.loading() = RouteAssignmentLoading;
  const factory RouteAssignmentState.noRoute() = RouteAssignmentNoRoute;

  const factory RouteAssignmentState.routeAssigned({
    required Route route,
    required List<WayPointWithContainer> waypoints,
  }) = RouteAssignmentAssigned;

  const factory RouteAssignmentState.error(String message) =
  RouteAssignmentError;
}

class WayPointWithContainer {
  const WayPointWithContainer({
    required this.wayPoint,
    required this.container,
  });

  final WayPoint wayPoint;
  final Container container;

  bool get isCompleted => wayPoint.isCompleted;

  bool get isPending => wayPoint.isPending;

  bool get isSkipped => wayPoint.isSkipped;

  bool get isCritical => container.isCritical;

  bool get requiresCollection => container.requiresCollection;

  int get sequenceOrder => wayPoint.sequenceOrder;

  String get address => '${container.latitude}, ${container.longitude}';

  double get fillPercentage => container.fillPercentage;
}

extension RouteAssignmentStateX on RouteAssignmentState {
  bool get hasRoute => this is RouteAssignmentAssigned;

  bool get isLoading => this is RouteAssignmentLoading;

  Route? get route => switch (this) {
    RouteAssignmentAssigned(route: final r) => r,
    _ => null,
  };

  List<WayPointWithContainer>? get waypoints => switch (this) {
    RouteAssignmentAssigned(waypoints: final w) => w,
    _ => null,
  };

  int get totalWaypoints => waypoints?.length ?? 0;

  int get completedWaypoints =>
      waypoints?.where((w) => w.isCompleted).length ?? 0;

  int get pendingWaypoints =>
      waypoints?.where((w) => w.isPending).length ?? 0;

  WayPointWithContainer? get nextWaypoint =>
      waypoints?.firstWhere((w) => w.isPending, orElse: () => waypoints!.first);
}