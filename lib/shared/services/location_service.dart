import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService {
  final Logger _logger = Logger();
  StreamSubscription<Position>? _positionSubscription;

  Future<bool> checkPermissions() async {bool serviceEnabled;LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logger.w('Los servicios de ubicación están deshabilitados');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _logger.w('Permisos de ubicación denegados');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.e('Permisos de ubicación denegados permanentemente');
      return false;
    }

    _logger.i('Permisos de ubicación concedidos');
    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _logger.i('Ubicación actual: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      _logger.e('Error al obtener ubicación: $e');
      return null;
    }
  }

  Stream<Position> startLocationTracking({int intervalSeconds = 60,}) {
    _logger.i('Iniciando tracking de ubicación (intervalo: ${intervalSeconds}s)');

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _logger.i('Tracking de ubicación detenido');
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2,) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  bool isNearWaypoint(Position currentPosition, double waypointLat, double waypointLon, {double radiusMeters = 50,}) {
    final distance = calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      waypointLat,
      waypointLon,
    );

    return distance <= radiusMeters;
  }
}
