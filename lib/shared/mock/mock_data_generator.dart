import 'package:uuid/uuid.dart';
import 'package:waste_track_driver_app/entities/container/model/entities/container.dart';
import 'package:waste_track_driver_app/entities/container/model/enums/container_status.dart';
import 'package:waste_track_driver_app/entities/container/model/enums/container_type.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';
import 'package:waste_track_driver_app/entities/route/model/enums/route_status.dart';
import 'package:waste_track_driver_app/entities/route/model/enums/route_type.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/entities/waypoint.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/enums/priority_level.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/enums/waypoint_status.dart';

class MockDataGenerator {
  static const _uuid = Uuid();

  // ✅ Coordenadas base para San Isidro/Miraflores, Lima
  static const double _baseLatitude = -12.043847;
  static const double _baseLongitude = -77.039591;

  // IDs fijos para consistencia
  static const String districtId = 'dist_45';
  static const String vehicleId = 'vehicle-001';

  /// Genera una ruta activa (en progreso) con waypoints
  static RouteWithWaypoints generateActiveRoute({String? driverId}) {
    final routeId = 'route-active-${_uuid.v4().substring(0, 8)}';
    final now = DateTime.now();

    final route = Route(
      id: routeId,
      districtId: districtId,
      vehicleId: vehicleId,
      driverId: driverId ?? 'USR-MHXL579K-PYD8Y76',
      routeType: RouteType.regular,
      status: RouteStatus.inProgress,
      scheduledStartAt: now.subtract(const Duration(minutes: 30)),
      startedAt: now.subtract(const Duration(minutes: 25)),
      createdAt: now.subtract(const Duration(hours: 2)),
      totalDistance: 12.5,
      estimatedDuration: const Duration(hours: 2, minutes: 30),
      collectionDuration: const Duration(hours: 1, minutes: 45),
      returnDuration: const Duration(minutes: 45),
      actualDuration: const Duration(minutes: 25),
      currentLatitude: _baseLatitude,
      currentLongitude: _baseLongitude,
      lastLocationUpdate: now.subtract(const Duration(seconds: 30)),
    );

    final waypointsWithContainers = _generateWaypoints(routeId, 8);

    return RouteWithWaypoints(
      route: route,
      waypointsWithContainers: waypointsWithContainers,
    );
  }

  /// Genera rutas completadas para el historial
  static List<RouteWithWaypoints> generateCompletedRoutes(int count, {String? driverId}) {
    final routes = <RouteWithWaypoints>[];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final routeId = 'route-completed-${_uuid.v4().substring(0, 8)}';
      final daysAgo = i + 1;
      final completedDate = now.subtract(Duration(days: daysAgo));

      final route = Route(
        id: routeId,
        districtId: districtId,
        vehicleId: vehicleId,
        driverId: driverId ?? 'USR-MHXL579K-PYD8Y76',
        routeType: RouteType.regular,
        status: RouteStatus.completed,
        scheduledStartAt: completedDate.subtract(const Duration(hours: 3)),
        startedAt: completedDate.subtract(const Duration(hours: 2, minutes: 55)),
        completedAt: completedDate,
        createdAt: completedDate.subtract(const Duration(hours: 4)),
        totalDistance: 10.0 + (i * 2.0),
        estimatedDuration: const Duration(hours: 2, minutes: 30),
        collectionDuration: const Duration(hours: 1, minutes: 45),
        returnDuration: const Duration(minutes: 45),
        actualDuration: Duration(hours: 2, minutes: 30 + (i * 5)),
      );

      final waypointsWithContainers = _generateWaypoints(
        routeId,
        8,
        isCompleted: true,
      );

      routes.add(RouteWithWaypoints(
        route: route,
        waypointsWithContainers: waypointsWithContainers,
      ));
    }

    return routes;
  }

  static List<WaypointWithContainer> _generateWaypoints(
      String routeId,
      int count, {
        bool isCompleted = false,
      }) {
    final waypoints = <WaypointWithContainer>[];
    final now = DateTime.now();

    // ✅ Coordenadas reales en San Isidro/Miraflores siguiendo calles principales
    final realLocations = [
      // Av. Arequipa (rumbo sur)
      {'lat': -12.043847, 'lng': -77.039591, 'address': 'Av. Arequipa 2500, San Isidro'},
      {'lat': -12.046234, 'lng': -77.040123, 'address': 'Av. Arequipa 2700, San Isidro'},
      {'lat': -12.048891, 'lng': -77.040687, 'address': 'Av. Arequipa 2900, San Isidro'},

      // Girando hacia Av. Javier Prado
      {'lat': -12.050123, 'lng': -77.041234, 'address': 'Av. Javier Prado Este 450, San Isidro'},
      {'lat': -12.050567, 'lng': -77.043891, 'address': 'Av. Javier Prado Este 280, San Isidro'},

      // Subiendo por Av. Conquistadores
      {'lat': -12.048234, 'lng': -77.045123, 'address': 'Av. Conquistadores 890, San Isidro'},
      {'lat': -12.045891, 'lng': -77.044567, 'address': 'Av. Conquistadores 1120, San Isidro'},

      // Regresando por Av. República de Panamá
      {'lat': -12.044123, 'lng': -77.042891, 'address': 'Av. República de Panamá 3450, San Isidro'},
    ];

    for (int i = 0; i < count && i < realLocations.length; i++) {
      final containerId = 'container-${_uuid.v4().substring(0, 8)}';
      final waypointId = 'waypoint-${_uuid.v4().substring(0, 8)}';

      final location = realLocations[i];
      final lat = location['lat'] as double;
      final lng = location['lng'] as double;
      final address = location['address'] as String;

      // Determinar el estado del waypoint
      WayPointStatus waypointStatus;
      DateTime? actualArrival;

      if (isCompleted) {
        waypointStatus = WayPointStatus.visited;
        actualArrival = now.subtract(Duration(hours: 2 - i ~/ 3, minutes: 45 - (i * 5)));
      } else {
        // Para ruta activa: primeros 3 visitados, resto pendiente
        if (i < 3) {
          waypointStatus = WayPointStatus.visited;
          actualArrival = now.subtract(Duration(minutes: 20 - (i * 5)));
        } else {
          waypointStatus = WayPointStatus.pending;
        }
      }

      final containerType = ContainerType.values[i % 3];

      final container = Container(
        id: containerId,
        latitude: lat,
        longitude: lng,
        volumeLiters: 1000,
        maxWeightKg: 500,
        containerType: containerType,
        status: ContainerStatus.active,
        districtId: districtId,
        collectionFrequencyDays: 3,
        currentFillLevel: 750 + (i * 20),
        createdAt: now.subtract(const Duration(days: 30)),
        lastCollectionDate: now.subtract(const Duration(days: 2)),
        lastReadingTimestamp: now.subtract(const Duration(hours: 1)),
      );

      final waypoint = WayPoint(
        id: waypointId,
        containerId: containerId,
        sequenceOrder: i + 1,
        priority: i % 4 == 0 ? PriorityLevel.high : PriorityLevel.medium,
        status: waypointStatus,
        estimatedArrivalTime: now.add(Duration(minutes: 10 + (i * 8))),
        actualArrivalTime: actualArrival,
        createdAt: now.subtract(const Duration(hours: 2)),
      );

      waypoints.add(WaypointWithContainer(
        waypoint: waypoint,
        container: container,
        address: address,
      ));
    }

    return waypoints;
  }

  /// Genera estadísticas básicas para el perfil
  static DriverStats generateDriverStats(List<RouteWithWaypoints> completedRoutes) {
    int totalContainers = 0;
    int totalRoutes = completedRoutes.length;
    double totalDistance = 0;

    for (final route in completedRoutes) {
      totalContainers += route.waypointsWithContainers.length;
      totalDistance += route.route.totalDistance;
    }

    return DriverStats(
      totalRoutesCompleted: totalRoutes,
      totalContainersCollected: totalContainers,
      totalDistanceKm: totalDistance,
    );
  }
}

/// Clase auxiliar para agrupar Route con sus Waypoints y Containers
class RouteWithWaypoints {
  final Route route;
  final List<WaypointWithContainer> waypointsWithContainers;

  RouteWithWaypoints({
    required this.route,
    required this.waypointsWithContainers,
  });
}

/// Clase auxiliar para Waypoint con Container y dirección
class WaypointWithContainer {
  final WayPoint waypoint;
  final Container container;
  final String address;

  WaypointWithContainer({
    required this.waypoint,
    required this.container,
    required this.address,
  });
}

/// Estadísticas del conductor
class DriverStats {
  final int totalRoutesCompleted;
  final int totalContainersCollected;
  final double totalDistanceKm;

  DriverStats({
    required this.totalRoutesCompleted,
    required this.totalContainersCollected,
    required this.totalDistanceKm,
  });

  String get formattedDistance {
    return '${totalDistanceKm.toStringAsFixed(1)} km';
  }
}