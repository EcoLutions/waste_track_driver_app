import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService {
  final Logger _logger = Logger();
  StreamSubscription<Position>? _positionSubscription;

  /// Verifica y solicita permisos de ubicación
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logger.w('Los servicios de ubicación están deshabilitados');
      return false;
    }

    // Verificar permisos
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

  /// Obtiene la ubicación actual
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _logger.i('Ubicación actual: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      _logger.e('Error al obtener ubicación: $e');
      return null;
    }
  }

  /// Inicia el tracking de ubicación
  /// [onLocationUpdate] se llama cada vez que hay una nueva ubicación
  /// [intervalSeconds] define cada cuántos segundos se actualiza
  Stream<Position> startLocationTracking({
    int intervalSeconds = 60,
  }) {
    _logger.i('Iniciando tracking de ubicación (intervalo: ${intervalSeconds}s)');

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualiza cada 10 metros
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Detiene el tracking de ubicación
  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _logger.i('Tracking de ubicación detenido');
  }

  /// Calcula la distancia entre dos puntos (en metros)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Verifica si el conductor está cerca de un waypoint (radio de 50 metros)
  bool isNearWaypoint(
    Position currentPosition,
    double waypointLat,
    double waypointLon, {
    double radiusMeters = 50,
  }) {
    final distance = calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      waypointLat,
      waypointLon,
    );

    return distance <= radiusMeters;
  }
}
