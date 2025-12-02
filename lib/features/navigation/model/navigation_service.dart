import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/enums/waypoint_status.dart';
import 'package:waste_track_driver_app/features/navigation/model/google_directions_service.dart';
import 'package:waste_track_driver_app/features/navigation/model/route_directions.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';

class NavigationService {
  final Logger _logger = Logger();
  final GoogleDirectionsService _directionsService = GoogleDirectionsService();

  /// Obtener el próximo waypoint pendiente
  WayPointWithContainer? getNextWaypoint(List<WayPointWithContainer> waypoints) {
    try {
      return waypoints.firstWhere(
            (w) => w.wayPoint.status == WayPointStatus.pending,
      );
    } catch (e) {
      _logger.w('No hay waypoints pendientes');
      return null;
    }
  }

  /// Calcular distancia al waypoint
  double? calculateDistanceToWaypoint(
      Position? currentPosition,
      WayPointWithContainer? waypoint,
      ) {
    if (currentPosition == null || waypoint == null) return null;

    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      waypoint.container.latitude,
      waypoint.container.longitude,
    );
  }

  /// Obtener la instrucción más cercana
  NavigationInstruction? getCurrentInstruction(
      Position? currentPosition,
      RouteDirections? directions,
      ) {
    if (currentPosition == null || directions == null || directions.instructions.isEmpty) {
      return null;
    }

    NavigationInstruction? closest;
    double minDistance = double.infinity;

    for (final instruction in directions.instructions) {
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        instruction.location.latitude,
        instruction.location.longitude,
      );

      // Solo considerar instrucciones adelante (distancia < 500m)
      if (distance < 500 && distance < minDistance) {
        minDistance = distance;
        closest = instruction;
      }
    }

    _logger.d('Instrucción más cercana: ${closest?.instruction} (${minDistance.toStringAsFixed(0)}m)');

    return closest ?? directions.instructions.first;
  }

  /// Cargar direcciones desde Google
  Future<RouteDirections?> loadDirections({
    required Position currentPosition,
    required List<WayPointWithContainer> waypoints,
  }) async {
    _logger.i('Cargando direcciones desde Google Directions API');

    if (waypoints.isEmpty) {
      _logger.w('No hay waypoints para cargar direcciones');
      return null;
    }

    // Ordenar waypoints por secuencia
    final sortedWaypoints = List<WayPointWithContainer>.from(waypoints)
      ..sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

    // Filtrar solo waypoints pendientes
    final pendingWaypoints = sortedWaypoints
        .where((w) => w.wayPoint.status == WayPointStatus.pending)
        .toList();

    if (pendingWaypoints.isEmpty) {
      _logger.i('No hay waypoints pendientes');
      return null;
    }

    _logger.i('Waypoints pendientes: ${pendingWaypoints.length}');

    final origin = LatLng(currentPosition.latitude, currentPosition.longitude);
    final destination = LatLng(
      pendingWaypoints.last.container.latitude,
      pendingWaypoints.last.container.longitude,
    );

    // Waypoints intermedios (todos excepto el último)
    final intermediateWaypoints = pendingWaypoints
        .take(pendingWaypoints.length - 1)
        .map((w) => LatLng(w.container.latitude, w.container.longitude))
        .toList();

    _logger.i('Origen: ${origin.latitude}, ${origin.longitude}');
    _logger.i('Destino: ${destination.latitude}, ${destination.longitude}');
    _logger.i('Intermedios: ${intermediateWaypoints.length}');

    final directions = await _directionsService.getDirections(
      origin: origin,
      destination: destination,
      waypoints: intermediateWaypoints,
    );

    if (directions != null) {
      _logger.i('Direcciones cargadas exitosamente');
      _logger.i('- Puntos en polyline: ${directions.polylinePoints.length}');
      _logger.i('- Instrucciones: ${directions.instructions.length}');
      _logger.i('- Distancia: ${directions.formattedDistance}');
      _logger.i('- Duración: ${directions.formattedDuration}');
    } else {
      _logger.e('No se pudieron cargar las direcciones');
    }

    return directions;
  }

  /// Verificar si está cerca del waypoint (radio de 50m)
  bool isNearWaypoint(
      Position currentPosition,
      WayPointWithContainer waypoint, {
        double radiusMeters = 50,
      }) {
    final distance = calculateDistanceToWaypoint(currentPosition, waypoint);
    if (distance == null) return false;

    return distance <= radiusMeters;
  }
}