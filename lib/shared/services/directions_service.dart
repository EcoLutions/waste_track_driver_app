import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class DirectionsService {
  final Logger _logger = Logger();

  static String get _googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<DirectionsResult?> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) async {
    try {
      _logger.i('🗺️ Obteniendo direcciones de ${origin.latitude},${origin.longitude} a ${destination.latitude},${destination.longitude}');

      final waypointsParam = waypoints != null && waypoints.isNotEmpty
          ? '&waypoints=optimize:true|${waypoints.map((w) => '${w.latitude},${w.longitude}').join('|')}'
          : '';

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=${origin.latitude},${origin.longitude}'
            '&destination=${destination.latitude},${destination.longitude}'
            '$waypointsParam'
            '&mode=driving'
            '&key=$_googleMapsApiKey',
      );

      _logger.i('Request URL: $url');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        _logger.e('Error en API: ${response.statusCode}');
        return _generateMockRoute(origin, destination, waypoints);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json['status'] != 'OK') {
        _logger.w('API status: ${json['status']} - usando ruta mock');
        return _generateMockRoute(origin, destination, waypoints);
      }

      final routes = json['routes'] as List<dynamic>;
      if (routes.isEmpty) {
        _logger.w('No routes found - usando ruta mock');
        return _generateMockRoute(origin, destination, waypoints);
      }

      final route = routes[0] as Map<String, dynamic>;
      final polyline = route['overview_polyline'] as Map<String, dynamic>;
      final points = _decodePolyline(polyline['points'] as String);

      final legs = route['legs'] as List<dynamic>;
      final instructions = <NavigationInstruction>[];

      for (final leg in legs) {
        final steps = leg['steps'] as List<dynamic>;
        for (final step in steps) {
          instructions.add(NavigationInstruction(
            instruction: _stripHtml(step['html_instructions'] as String),
            distance: (step['distance'] as Map<String, dynamic>)['text'] as String,
            duration: (step['duration'] as Map<String, dynamic>)['text'] as String,
            location: LatLng(
              (step['start_location'] as Map<String, dynamic>)['lat'] as double,
              (step['start_location'] as Map<String, dynamic>)['lng'] as double,
            ),
          ));
        }
      }

      double totalDistanceMeters = 0;
      int totalDurationSeconds = 0;

      for (final leg in legs) {
        totalDistanceMeters += ((leg['distance'] as Map<String, dynamic>)['value'] as num).toDouble();
        totalDurationSeconds += ((leg['duration'] as Map<String, dynamic>)['value'] as num).toInt();
      }

      _logger.i('Ruta obtenida: ${points.length} puntos, ${instructions.length} instrucciones');

      return DirectionsResult(
        polylinePoints: points,
        totalDistance: totalDistanceMeters / 1000, // km
        totalDuration: Duration(seconds: totalDurationSeconds),
        bounds: _calculateBounds(points),
        instructions: instructions,
      );
    } catch (e) {
      _logger.e('Error al obtener direcciones: $e - usando ruta mock');
      return _generateMockRoute(origin, destination, waypoints);
    }
  }

  /// Decodificar polyline de Google
  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ');
  }

  DirectionsResult _generateMockRoute(
      LatLng origin,
      LatLng destination,
      List<LatLng>? waypoints,
      ) {
    _logger.i('Generando ruta mock');

    final allPoints = <LatLng>[
      origin,
      if (waypoints != null) ...waypoints,
      destination,
    ];

    final smoothPoints = <LatLng>[];

    for (int i = 0; i < allPoints.length - 1; i++) {
      final start = allPoints[i];
      final end = allPoints[i + 1];

      for (int j = 0; j <= 10; j++) {
        final t = j / 10.0;
        final lat = start.latitude + (end.latitude - start.latitude) * t;
        final lng = start.longitude + (end.longitude - start.longitude) * t;
        smoothPoints.add(LatLng(lat, lng));
      }
    }

    final distance = _calculateRouteDistance(smoothPoints);

    return DirectionsResult(
      polylinePoints: smoothPoints,
      totalDistance: distance,
      totalDuration: Duration(minutes: (distance * 2).toInt()),
      bounds: _calculateBounds(smoothPoints),
      instructions: [],
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

  double _toRadians(double degrees) => degrees * (pi / 180);

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (final point in points) {
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

class DirectionsResult {
  const DirectionsResult({
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    required this.bounds,
    required this.instructions,
  });

  final List<LatLng> polylinePoints;
  final double totalDistance; // km
  final Duration totalDuration;
  final LatLngBounds bounds;
  final List<NavigationInstruction> instructions;

  String get formattedDistance => totalDistance < 1.0
      ? '${(totalDistance * 1000).toStringAsFixed(0)} m'
      : '${totalDistance.toStringAsFixed(2)} km';

  String get formattedDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}

class NavigationInstruction {
  const NavigationInstruction({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.location,
  });

  final String instruction;
  final String distance;
  final String duration;
  final LatLng location;
}