import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';


class DirectionsService {
  final Logger _logger = Logger();
  final PolylinePoints _polylinePoints = PolylinePoints(apiKey: DirectionsService._googleMapsApiKey);

  /// API Key de Google Maps
static String get _googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';


  Future<DirectionsResult?> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) async {
    try {
      _logger.i('Obteniendo direcciones de ${origin.latitude},${origin.longitude} a ${destination.latitude},${destination.longitude}');

      // Construir waypoints para la API
      final waypointsStr = waypoints
          ?.map((w) => PolylineWayPoint(
        location: '${w.latitude},${w.longitude}',
      ))
          .toList();

      // Obtener la ruta
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
          wayPoints: waypointsStr ?? [],
        ),
      );

      if (result.points.isEmpty) {
        _logger.w('No se encontraron rutas - usando ruta mock');

        // ✅ NUEVO: Generar ruta mock si la API falla
        return _generateMockRoute(origin, destination, waypoints);
      }

      _logger.i('Ruta obtenida con ${result.points.length} puntos');

      final polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      final totalDistance = _calculateRouteDistance(polylineCoordinates);

      return DirectionsResult(
        polylinePoints: polylineCoordinates,
        totalDistance: totalDistance,
        bounds: _calculateBounds(polylineCoordinates),
      );
    } catch (e) {
      _logger.e('Error al obtener direcciones: $e - usando ruta mock');
      // ✅ NUEVO: En caso de error, generar ruta mock
      return _generateMockRoute(origin, destination, waypoints);
    }
  }

  // ✅ NUEVO: Generar ruta mock
  DirectionsResult _generateMockRoute(
      LatLng origin,
      LatLng destination,
      List<LatLng>? waypoints,
      ) {
    _logger.i('🎭 Generando ruta mock');

    final allPoints = <LatLng>[
      origin,
      if (waypoints != null) ...waypoints,
      destination,
    ];

    // Generar puntos intermedios suaves entre cada par de puntos
    final smoothPoints = <LatLng>[];

    for (int i = 0; i < allPoints.length - 1; i++) {
      final start = allPoints[i];
      final end = allPoints[i + 1];

      // Generar 10 puntos intermedios entre cada par
      for (int j = 0; j <= 10; j++) {
        final t = j / 10.0;
        final lat = start.latitude + (end.latitude - start.latitude) * t;
        final lng = start.longitude + (end.longitude - start.longitude) * t;
        smoothPoints.add(LatLng(lat, lng));
      }
    }

    final distance = _calculateRouteDistance(smoothPoints);

    _logger.i('✅ Ruta mock generada con ${smoothPoints.length} puntos');

    return DirectionsResult(
      polylinePoints: smoothPoints,
      totalDistance: distance,
      bounds: _calculateBounds(smoothPoints),
    );
  }

  double _calculateRouteDistance(List<LatLng> points) {
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _calculateDistance(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return totalDistance / 1000;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (final point in points) {
      if (minLat == null || point.latitude < minLat) {
        minLat = point.latitude;
      }
      if (maxLat == null || point.latitude > maxLat) {
        maxLat = point.latitude;
      }
      if (minLng == null || point.longitude < minLng) {
        minLng = point.longitude;
      }
      if (maxLng == null || point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }
}

class DirectionsResult {
  DirectionsResult({
    required this.polylinePoints,
    required this.totalDistance,
    required this.bounds,
  });
  final List<LatLng> polylinePoints;
  final double totalDistance;
  final LatLngBounds bounds;

  String get formattedDistance => '${totalDistance.toStringAsFixed(2)} km';
}