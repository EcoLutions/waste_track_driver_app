import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/features/navigation/model/route_directions.dart';

class GoogleDirectionsService {
  final Logger _logger = Logger();

  static String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<RouteDirections?> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) async {
    try {
      _logger.i(' Obteniendo ruta de Google Directions API');
      _logger.i('Origen: ${origin.latitude}, ${origin.longitude}');
      _logger.i('Destino: ${destination.latitude}, ${destination.longitude}');
      _logger.i('Waypoints: ${waypoints?.length ?? 0}');

      // ⭐ SI NO HAY API KEY, usar mock directamente
      if (_apiKey.isEmpty) {
        _logger.w('⚠️ No API Key configurada, usando ruta mock');
        return _generateMockRoute(origin, destination, waypoints);
      }

      // Construir waypoints en el formato correcto
      String waypointsParam = '';
      if (waypoints != null && waypoints.isNotEmpty) {
        final waypointsList = waypoints
            .map((w) => '${w.latitude},${w.longitude}')
            .join('|');
        waypointsParam = '&waypoints=optimize:true|$waypointsList';
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=${origin.latitude},${origin.longitude}'
            '&destination=${destination.latitude},${destination.longitude}'
            '$waypointsParam'
            '&mode=driving'
            '&language=es'
            '&units=metric'
            '&key=$_apiKey',
      );

      _logger.i('🌐 Calling Google Directions API...');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logger.w('⏱️ API timeout, usando ruta mock');
          throw TimeoutException('API timeout');
        },
      );

      if (response.statusCode != 200) {
        _logger.e('❌ Error HTTP: ${response.statusCode}');
        _logger.w('⚠️ Usando ruta mock por error HTTP');
        return _generateMockRoute(origin, destination, waypoints);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final status = json['status'] as String;
      _logger.i('API Status: $status');

      if (status != 'OK') {
        _logger.e('API Error: $status');
        if (json.containsKey('error_message')) {
          _logger.e('Error message: ${json['error_message']}');
        }
        _logger.w(' Usando ruta mock por error de API');
        return _generateMockRoute(origin, destination, waypoints);
      }

      final routes = json['routes'] as List<dynamic>;
      if (routes.isEmpty) {
        _logger.e('No se encontraron rutas');
        return _generateMockRoute(origin, destination, waypoints);
      }

      final route = routes[0] as Map<String, dynamic>;

      // Decodificar polyline
      final overviewPolyline = route['overview_polyline'] as Map<String, dynamic>;
      final encodedPoints = overviewPolyline['points'] as String;
      final polylinePoints = _decodePolyline(encodedPoints);

      _logger.i('Polyline decodificada: ${polylinePoints.length} puntos');

      // Extraer legs (tramos de la ruta)
      final legs = route['legs'] as List<dynamic>;
      final instructions = <NavigationInstruction>[];
      double totalDistanceMeters = 0;
      int totalDurationSeconds = 0;

      for (final leg in legs) {
        final distance = leg['distance'] as Map<String, dynamic>;
        final duration = leg['duration'] as Map<String, dynamic>;

        totalDistanceMeters += (distance['value'] as num).toDouble();
        totalDurationSeconds += (duration['value'] as num).toInt();

        final steps = leg['steps'] as List<dynamic>;

        for (final step in steps) {
          final htmlInstructions = step['html_instructions'] as String;
          final stepDistance = step['distance'] as Map<String, dynamic>;
          final stepDuration = step['duration'] as Map<String, dynamic>;
          final startLocation = step['start_location'] as Map<String, dynamic>;

          instructions.add(NavigationInstruction(
            instruction: _cleanHtml(htmlInstructions),
            distanceText: stepDistance['text'] as String,
            distanceMeters: (stepDistance['value'] as num).toDouble(),
            durationText: stepDuration['text'] as String,
            durationSeconds: (stepDuration['value'] as num).toInt(),
            location: LatLng(
              (startLocation['lat'] as num).toDouble(),
              (startLocation['lng'] as num).toDouble(),
            ),
          ));
        }
      }

      _logger.i(' Ruta REAL de Google procesada:');
      _logger.i('   - ${polylinePoints.length} puntos en polyline');
      _logger.i('   - ${instructions.length} instrucciones');
      _logger.i('   - ${(totalDistanceMeters / 1000).toStringAsFixed(2)} km');
      _logger.i('   - ${Duration(seconds: totalDurationSeconds).inMinutes} min');

      return RouteDirections(
        polylinePoints: polylinePoints,
        instructions: instructions,
        totalDistanceMeters: totalDistanceMeters,
        totalDurationSeconds: totalDurationSeconds,
      );

    } catch (e, stackTrace) {
      _logger.e('Exception obteniendo direcciones: $e');
      _logger.e('Stack trace: $stackTrace');
      _logger.w('Usando ruta mock por excepción');
      return _generateMockRoute(origin, destination, waypoints);
    }
  }

  /// Generar ruta mock para desarrollo/testing
  RouteDirections _generateMockRoute(
      LatLng origin,
      LatLng destination,
      List<LatLng>? waypoints,
      ) {
    _logger.i('🎭 Generando ruta MOCK para testing/desarrollo');

    final allPoints = <LatLng>[
      origin,
      if (waypoints != null) ...waypoints,
      destination,
    ];

    _logger.i('📍 Puntos de la ruta mock: ${allPoints.length}');

    // Generar polyline suave con curvas
    final smoothPoints = <LatLng>[];
    for (int i = 0; i < allPoints.length - 1; i++) {
      final start = allPoints[i];
      final end = allPoints[i + 1];

      // 30 puntos intermedios para cada segmento (más suave)
      for (int j = 0; j <= 30; j++) {
        final t = j / 30.0;

        // Interpolación con curva (no lineal)
        final easedT = _easeInOutCubic(t);

        final lat = start.latitude + (end.latitude - start.latitude) * easedT;
        final lng = start.longitude + (end.longitude - start.longitude) * easedT;

        smoothPoints.add(LatLng(lat, lng));
      }
    }

    // Calcular distancia total
    double totalDistance = 0;
    for (int i = 0; i < smoothPoints.length - 1; i++) {
      totalDistance += _calculateDistance(
        smoothPoints[i].latitude,
        smoothPoints[i].longitude,
        smoothPoints[i + 1].latitude,
        smoothPoints[i + 1].longitude,
      );
    }

    // Generar instrucciones mock
    final instructions = <NavigationInstruction>[];

    for (int i = 0; i < allPoints.length - 1; i++) {
      final segmentDistance = _calculateDistance(
        allPoints[i].latitude,
        allPoints[i].longitude,
        allPoints[i + 1].latitude,
        allPoints[i + 1].longitude,
      );

      final instructionText = i == 0
          ? 'Dirígete hacia el primer punto de recolección'
          : i == allPoints.length - 2
          ? 'Continúa hacia el último punto de recolección'
          : 'Continúa hacia el siguiente punto de recolección';

      instructions.add(NavigationInstruction(
        instruction: instructionText,
        distanceText: segmentDistance < 1000
            ? '${segmentDistance.toStringAsFixed(0)} m'
            : '${(segmentDistance / 1000).toStringAsFixed(2)} km',
        distanceMeters: segmentDistance,
        durationText: '${(segmentDistance / 1000 * 2).toStringAsFixed(0)} min',
        durationSeconds: ((segmentDistance / 1000) * 2 * 60).toInt(),
        location: allPoints[i],
      ));
    }

    final totalDuration = ((totalDistance / 1000) * 2 * 60).toInt(); // 2 min/km estimado

    _logger.i('Ruta MOCK generada:');
    _logger.i(' - ${smoothPoints.length} puntos en polyline');
    _logger.i(' - ${instructions.length} instrucciones');
    _logger.i(' - ${(totalDistance / 1000).toStringAsFixed(2)} km');
    _logger.i(' - ${Duration(seconds: totalDuration).inMinutes} min estimados');

    return RouteDirections(
      polylinePoints: smoothPoints,
      instructions: instructions,
      totalDistanceMeters: totalDistance,
      totalDurationSeconds: totalDuration,
    );
  }

  /// Función de ease para transiciones suaves
  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
  }

  /// Calcular distancia entre dos puntos (Haversine)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // metros

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (pi / 180);

  /// Decodificar polyline de Google (algoritmo estándar)
  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final len = encoded.length;
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

      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  /// Limpiar HTML de las instrucciones
  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&#39;', "'")
        .trim();
  }
}

class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;
}