import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/entities/route/api/repositories/route_repository.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';
import 'package:waste_track_driver_app/entities/route/model/enums/route_status.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';
import 'package:waste_track_driver_app/shared/mock/mock_data_generator.dart';

class MockRouteRepository implements RouteRepository {
  final List<Route> _routes = [];
  final List<RouteWithWaypoints> _routeData = [];
  final Logger _logger = Logger();

  MockRouteRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _logger.i('📦 MockRouteRepository initializing (empty - will generate on demand)');
  }

  /// ✅ Método para asegurar que existe una ruta para un conductor
  void ensureRouteForDriver(String driverId) {
    // Verificar si ya existe una ruta activa para este conductor
    final existingRoute = _routes.where(
            (r) => r.driverId == driverId &&
            (r.status == RouteStatus.assigned || r.status == RouteStatus.inProgress)
    ).firstOrNull;

    if (existingRoute != null) {
      _logger.i('✅ Route already exists for driver $driverId: ${existingRoute.id}');
      return;
    }

    // Crear nueva ruta para este conductor
    _logger.i('🎯 Creating mock route for driver: $driverId');

    final activeRoute = MockDataGenerator.generateActiveRoute(driverId: driverId);
    _routes.add(activeRoute.route);
    _routeData.add(activeRoute);

    _logger.i('✅ Mock route created:');
    _logger.i('   ID: ${activeRoute.route.id}');
    _logger.i('   Driver: ${activeRoute.route.driverId}');
    _logger.i('   District: ${activeRoute.route.districtId}');
    _logger.i('   Status: ${activeRoute.route.status}');
    _logger.i('   Waypoints: ${activeRoute.waypointsWithContainers.length}');

    // Generar rutas completadas también
    final completedRoutes = MockDataGenerator.generateCompletedRoutes(5, driverId: driverId);
    for (final routeData in completedRoutes) {
      _routes.add(routeData.route);
      _routeData.add(routeData);
    }

    _logger.i('📊 Total routes for driver $driverId: ${_routes.where((r) => r.driverId == driverId).length}');
  }

  @override
  Future<Resource<List<Route>>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logger.i('📋 Returning ${_routes.length} total routes');

    // Debug: Imprimir todas las rutas
    for (final route in _routes) {
      _logger.d('   Route: ${route.id}, driver: ${route.driverId}, status: ${route.status}');
    }

    return Success(_routes);
  }

  @override
  Future<Resource<Route>> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final route = _routes.firstWhere((r) => r.id == id);
      _logger.i('✅ Found route: $id');
      return Success(route);
    } catch (e) {
      _logger.w('❌ Route not found: $id');
      return const Failure(
        message: 'Route not found',
        statusCode: 404,
      );
    }
  }

  @override
  Future<Resource<List<Route>>> getActiveByDistrictId(String districtId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final activeRoutes = _routes.where((r) =>
    r.districtId == districtId &&
        (r.status == RouteStatus.assigned || r.status == RouteStatus.inProgress)
    ).toList();

    _logger.i('📍 Found ${activeRoutes.length} active routes for district: $districtId');
    return Success(activeRoutes);
  }

  @override
  Future<Resource<Route>> create(Route route) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _routes.add(route);
    return Success(route);
  }

  @override
  Future<Resource<Route>> update(Route route) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _routes.indexWhere((r) => r.id == route.id);
    if (index != -1) {
      _routes[index] = route;
      return Success(route);
    }

    return const Failure(
      message: 'Route not found',
      statusCode: 404,
    );
  }

  @override
  Future<Resource<void>> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _routes.removeWhere((r) => r.id == id);
    return const Success(null);
  }

  @override
  Future<Resource<Route>> generateOptimizedWaypoints(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getById(id);
  }

  RouteWithWaypoints? getRouteData(String routeId) {
    try {
      final data = _routeData.firstWhere((r) => r.route.id == routeId);
      _logger.i('✅ Found route data for: $routeId with ${data.waypointsWithContainers.length} waypoints');
      return data;
    } catch (e) {
      _logger.w('⚠️ Route data not found: $routeId');
      return null;
    }
  }

  List<RouteWithWaypoints> getAllRouteData() {
    return _routeData;
  }
}
