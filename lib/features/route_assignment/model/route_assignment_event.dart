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