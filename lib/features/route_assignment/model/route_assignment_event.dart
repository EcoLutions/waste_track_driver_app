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

final class CompleteRoute extends RouteAssignmentEvent {
  const CompleteRoute();
}

final class MarkWaypointAsVisited extends RouteAssignmentEvent {
  const MarkWaypointAsVisited({required this.waypointId});

  final String waypointId;

  @override
  List<Object?> get props => [waypointId];
}

class UpdateDriverLocation extends RouteAssignmentEvent {
  const UpdateDriverLocation({
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speed,
  });

  final double latitude;
  final double longitude;
  final double heading;
  final double speed;

  @override
  List<Object?> get props => [latitude, longitude, heading, speed];
}