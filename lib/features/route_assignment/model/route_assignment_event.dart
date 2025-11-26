import 'package:equatable/equatable.dart';

sealed class RouteAssignmentEvent extends Equatable {
  const RouteAssignmentEvent();

  @override
  List<Object?> get props => [];
}

final class LoadActiveRoute extends RouteAssignmentEvent {
  const LoadActiveRoute({
    required this.driverId,
    required this.districtId,
  });

  final String driverId;
  final String districtId;

  @override
  List<Object?> get props => [driverId, districtId];
}

final class RefreshRoute extends RouteAssignmentEvent {
  const RefreshRoute();
}

final class ClearRoute extends RouteAssignmentEvent {
  const ClearRoute();
}

final class GenerateWaypoints extends RouteAssignmentEvent {
  const GenerateWaypoints({required this.routeId});

  final String routeId;

  @override
  List<Object?> get props => [routeId];
}

final class MarkWaypointAsVisited extends RouteAssignmentEvent {
  const MarkWaypointAsVisited({required this.waypointId});

  final String waypointId;

  @override
  List<Object?> get props => [waypointId];
}
