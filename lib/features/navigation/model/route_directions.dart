import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteDirections {
  const RouteDirections({
    required this.polylinePoints,
    required this.instructions,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
  });

  final List<LatLng> polylinePoints;
  final List<NavigationInstruction> instructions;
  final double totalDistanceMeters;
  final int totalDurationSeconds;

  String get formattedDistance {
    if (totalDistanceMeters < 1000) {
      return '${totalDistanceMeters.toStringAsFixed(0)} m';
    }
    return '${(totalDistanceMeters / 1000).toStringAsFixed(2)} km';
  }

  String get formattedDuration {
    final duration = Duration(seconds: totalDurationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }

  LatLngBounds get bounds {
    double? minLat, maxLat, minLng, maxLng;

    for (final point in polylinePoints) {
      if (minLat == null || point.latitude < minLat) minLat = point.latitude;
      if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
      if (minLng == null || point.longitude < minLng) minLng = point.longitude;
      if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }
}

/// Instrucción individual de navegación
class NavigationInstruction {
  const NavigationInstruction({
    required this.instruction,
    required this.distanceText,
    required this.distanceMeters,
    required this.durationText,
    required this.durationSeconds,
    required this.location,
  });

  final String instruction;
  final String distanceText;
  final double distanceMeters;
  final String durationText;
  final int durationSeconds;
  final LatLng location;

  /// Detectar tipo de maniobra basándose en el texto
  NavigationManeuver get maneuver {
    final lower = instruction.toLowerCase();

    if (lower.contains('gira a la derecha') || lower.contains('turn right')) {
      return NavigationManeuver.turnRight;
    } else if (lower.contains('gira a la izquierda') || lower.contains('turn left')) {
      return NavigationManeuver.turnLeft;
    } else if (lower.contains('gira ligeramente a la derecha')) {
      return NavigationManeuver.turnSlightRight;
    } else if (lower.contains('gira ligeramente a la izquierda')) {
      return NavigationManeuver.turnSlightLeft;
    } else if (lower.contains('gira fuertemente a la derecha')) {
      return NavigationManeuver.turnSharpRight;
    } else if (lower.contains('gira fuertemente a la izquierda')) {
      return NavigationManeuver.turnSharpLeft;
    } else if (lower.contains('rotonda') || lower.contains('roundabout')) {
      return NavigationManeuver.roundabout;
    } else if (lower.contains('continúa') || lower.contains('continue') || lower.contains('sigue')) {
      return NavigationManeuver.straight;
    }

    return NavigationManeuver.straight;
  }
}

enum NavigationManeuver {
  straight,
  turnLeft,
  turnRight,
  turnSlightLeft,
  turnSlightRight,
  turnSharpLeft,
  turnSharpRight,
  roundabout,
}