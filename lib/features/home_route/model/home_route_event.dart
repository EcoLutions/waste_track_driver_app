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