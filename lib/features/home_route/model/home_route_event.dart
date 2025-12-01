import 'package:equatable/equatable.dart';

sealed class HomeRouteEvent extends Equatable {
  const HomeRouteEvent();

  @override
  List<Object?> get props => [];
}

final class LoadActiveRoute extends HomeRouteEvent {
  const LoadActiveRoute({
    required this.driverId,
    required this.districtId,
  });

  final String driverId;
  final String districtId;

  @override
  List<Object?> get props => [driverId, districtId];
}

final class RefreshActiveRoute extends HomeRouteEvent {
  const RefreshActiveRoute({
    required this.driverId,
    required this.districtId,
  });

  final String driverId;
  final String districtId;

  @override
  List<Object?> get props => [driverId, districtId];
}

final class ClearRoute extends HomeRouteEvent {
  const ClearRoute();
}

final class StartRoute extends HomeRouteEvent {
  const StartRoute({
    required this.routeId,
  });
  final String routeId;

  @override
  List<Object?> get props => [routeId];
}

final class RouteActivatedFromWebSocket extends HomeRouteEvent {
  const RouteActivatedFromWebSocket({
    required this.routeId,
    required this.driverId,
  });

  final String routeId;
  final String driverId;

  @override
  List<Object?> get props => [routeId, driverId];
}