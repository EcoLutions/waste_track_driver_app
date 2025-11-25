import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_event.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_repository.dart';
import 'package:waste_track_driver_app/features/route_assignment/model/route_assignment_state.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class RouteAssignmentBloc
    extends Bloc<RouteAssignmentEvent, RouteAssignmentState> {
  RouteAssignmentBloc({
    required RouteAssignmentRepository routeAssignmentRepository,
  })  : _routeAssignmentRepository = routeAssignmentRepository,
        super(const RouteAssignmentState.initial()) {
    on<LoadActiveRoute>(_onLoadActiveRoute);
    on<RefreshRoute>(_onRefreshRoute);
    on<ClearRoute>(_onClearRoute);
  }

  final RouteAssignmentRepository _routeAssignmentRepository;
  final Logger _logger = Logger();

  String? _currentRouteId;

  // ==================== LOAD ACTIVE ROUTE ====================

  Future<void> _onLoadActiveRoute(
      LoadActiveRoute event,
      Emitter<RouteAssignmentState> emit,
      ) async {
    _logger.i('🚀 Loading active route for driver: ${event.driverId}');
    emit(const RouteAssignmentState.loading());

    try {
      final result = await _routeAssignmentRepository.loadActiveRouteForDriver(
        event.driverId,
      );

      _logger.i('📦 Repository returned: ${result.runtimeType}');

      switch (result) {
        case Success(data: final routeData):
          _currentRouteId = routeData.route.id;
          _logger.i('✅ Route loaded successfully: ${routeData.route.id}');
          _logger.i('📍 Total waypoints: ${routeData.totalWaypoints}');

          emit(RouteAssignmentState.routeAssigned(
            route: routeData.route,
            waypoints: routeData.wayPointsWithContainers,
          ));
          break;

        case Failure(message: final msg):
          _logger.w('⚠️ Repository failure: $msg');

          // Si no hay ruta, no es error, es estado normal
          if (msg.contains('No active route found') ||
              msg.contains('No se encontró')) {
            _logger.i('ℹ️ No active route found for driver - This is OK');
            emit(const RouteAssignmentState.noRoute());
          } else {
            _logger.e('❌ Error loading route: $msg');
            emit(RouteAssignmentState.error(msg));
          }
          break;
      }
    } catch (e, stackTrace) {
      _logger.e('💥 Exception in _onLoadActiveRoute: $e');
      _logger.e('StackTrace: $stackTrace');
      emit(RouteAssignmentState.error('Error inesperado: $e'));
    }
  }

  // ==================== REFRESH ROUTE ====================

  Future<void> _onRefreshRoute(
      RefreshRoute event,
      Emitter<RouteAssignmentState> emit,
      ) async {
    if (_currentRouteId == null) {
      _logger.w('⚠️ Cannot refresh: no current route');
      return;
    }

    _logger.i('🔄 Refreshing route: $_currentRouteId');
    emit(const RouteAssignmentState.loading());

    try {
      final result =
      await _routeAssignmentRepository.refreshRoute(_currentRouteId!);

      switch (result) {
        case Success(data: final routeData):
          _logger.i('✅ Route refreshed successfully');

          emit(RouteAssignmentState.routeAssigned(
            route: routeData.route,
            waypoints: routeData.wayPointsWithContainers,
          ));
          break;

        case Failure(message: final msg):
          _logger.e('❌ Error refreshing route: $msg');
          emit(RouteAssignmentState.error(msg));
          break;
      }
    } catch (e, stackTrace) {
      _logger.e('💥 Exception in _onRefreshRoute: $e');
      _logger.e('StackTrace: $stackTrace');
      emit(RouteAssignmentState.error('Error inesperado: $e'));
    }
  }

  // ==================== CLEAR ROUTE ====================

  Future<void> _onClearRoute(
      ClearRoute event,
      Emitter<RouteAssignmentState> emit,
      ) async {
    _logger.i('🧹 Clearing route');
    _currentRouteId = null;
    emit(const RouteAssignmentState.noRoute());
  }
}