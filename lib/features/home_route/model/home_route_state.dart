import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';

part 'home_route_state.freezed.dart';

@freezed
sealed class HomeRouteState with _$HomeRouteState {
  const factory HomeRouteState.initial() = HomeRouteInitial;

  const factory HomeRouteState.loading() = HomeRouteLoading;

  const factory HomeRouteState.notFound() = HomeRouteNotFound;

  const factory HomeRouteState.found({
    required Route route
  }) = HomeRouteFound;

  const factory HomeRouteState.error(String message) = HomeRouteError;
}

extension HomeRouteStateX on HomeRouteState {
  bool get isLoading => this is HomeRouteLoading;

  bool get hasRoute => this is HomeRouteFound;

  Route? get route => switch (this) {
    HomeRouteFound(route: final r) => r,
    _ => null,
  };
}