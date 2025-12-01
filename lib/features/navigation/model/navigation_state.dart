import 'package:geolocator/geolocator.dart';
import 'package:waste_track_driver_app/features/navigation/model/route_directions.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';

class NavigationState {
  const NavigationState({
    required this.isNavigationMode,
    required this.currentPosition,
    required this.directions,
    required this.currentInstruction,
    required this.nextWaypoint,
    required this.distanceToNextWaypoint,
  });

  final bool isNavigationMode;
  final Position? currentPosition;
  final RouteDirections? directions;
  final NavigationInstruction? currentInstruction;
  final WayPointWithContainer? nextWaypoint;
  final double? distanceToNextWaypoint;

  NavigationState copyWith({
    bool? isNavigationMode,
    Position? currentPosition,
    RouteDirections? directions,
    NavigationInstruction? currentInstruction,
    WayPointWithContainer? nextWaypoint,
    double? distanceToNextWaypoint,
  }) {
    return NavigationState(
      isNavigationMode: isNavigationMode ?? this.isNavigationMode,
      currentPosition: currentPosition ?? this.currentPosition,
      directions: directions ?? this.directions,
      currentInstruction: currentInstruction ?? this.currentInstruction,
      nextWaypoint: nextWaypoint ?? this.nextWaypoint,
      distanceToNextWaypoint: distanceToNextWaypoint ?? this.distanceToNextWaypoint,
    );
  }

  static NavigationState initial() {
    return const NavigationState(
      isNavigationMode: false,
      currentPosition: null,
      directions: null,
      currentInstruction: null,
      nextWaypoint: null,
      distanceToNextWaypoint: null,
    );
  }
}