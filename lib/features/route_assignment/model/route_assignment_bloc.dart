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
    on<CompleteRoute>(_onCompleteRoute);
    on<GenerateWaypoints>(_onGenerateWaypoints);
    on<MarkWaypointAsVisited>(_onMarkWaypointAsVisited);
    on<UpdateDriverLocation>(_onUpdateDriverLocation);
  }

  final RouteAssignmentRepository _routeAssignmentRepository;
  final Logger _logger = Logger();

  String? _currentRouteId;

  Future<void> _onLoadActiveRoute(LoadActiveRoute event, Emitter<RouteAssignmentState> emit,) async {
    _logger.i('🚀 Loading active route for driver: ${event.driverId} in district: ${event.districtId}');
    emit(const RouteAssignmentState.loading());

    try {
      final result = await _routeAssignmentRepository.loadActiveRouteForDriver(
        driverId: event.driverId,
        districtId: event.districtId,
      );

      _logger.i('📦 Repository returned: ${result.runtimeType}');

      switch (result) {
        case Success(data: final routeData):
          _currentRouteId = routeData.route.id;
          _logger.i('✅ Route loaded successfully: ${routeData.route.id}');
          _logger.i('📍 Total waypoints: ${routeData.totalWaypoints}');

          if (routeData.wayPointsWithContainers.isEmpty) {
            _logger.i('ℹ️ Route has no waypoints - needs generation');
          }

          emit(RouteAssignmentState.routeAssigned(
            route: routeData.route,
            waypoints: routeData.wayPointsWithContainers,
          ));
          break;

        case Failure(message: final msg, statusCode: final code):
          _logger.w('⚠️ Repository failure: $msg (code: $code)');

          if (msg.contains('No active route found') ||
              msg.contains('No se encontró') ||
              code == 404) {
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

  Future<void> _onRefreshRoute(RefreshRoute event, Emitter<RouteAssignmentState> emit,) async {
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

  Future<void> _onClearRoute(ClearRoute event, Emitter<RouteAssignmentState> emit,) async {
    _logger.i('🧹 Clearing route');
    _currentRouteId = null;
    emit(const RouteAssignmentState.noRoute());
  }

  Future<void> _onCompleteRoute(CompleteRoute event, Emitter<RouteAssignmentState> emit,) async {
    _logger.i('🏁 Completing route');
    emit(const RouteAssignmentState.loading());

    try {
      final result = await _routeAssignmentRepository.completeRoute(_currentRouteId!);

      switch (result) {
        case Success(data: final _):
          _logger.i('✅ Route completed successfully');
          emit(const RouteAssignmentState.noRoute());
          break;
        case Failure(message: final msg):
          _logger.e('❌ Error completing route: $msg');
          emit(RouteAssignmentState.error(msg));
          break;
      }
    } catch (e, stackTrace) {
      _logger.e('💥 Exception in _onCompleteRoute: $e');
      _logger.e('StackTrace: $stackTrace');
      emit(RouteAssignmentState.error('Error inesperado: $e'));
    }
  }

  Future<void> _onGenerateWaypoints(GenerateWaypoints event, Emitter<RouteAssignmentState> emit,) async {
    _logger.i('🗺️ Generating optimized waypoints for route: ${event.routeId}');
    emit(const RouteAssignmentState.loading());

    try {
      final result =
          await _routeAssignmentRepository.generateOptimizedWaypoints(event.routeId);

      switch (result) {
        case Success(data: final routeData):
          _currentRouteId = routeData.route.id;
          _logger.i('✅ Waypoints generated successfully');
          _logger.i('📍 Total waypoints: ${routeData.totalWaypoints}');
          _logger.i('📏 Distance: ${routeData.route.formattedTotalDistance}');
          _logger.i('⏱️ Duration: ${routeData.route.formattedEstimatedDuration}');

          emit(RouteAssignmentState.routeAssigned(
            route: routeData.route,
            waypoints: routeData.wayPointsWithContainers,
          ));
          break;

        case Failure(message: final msg):
          _logger.e('❌ Error generating waypoints: $msg');
          emit(RouteAssignmentState.error(msg));
          break;
      }
    } catch (e, stackTrace) {
      _logger.e('💥 Exception in _onGenerateWaypoints: $e');
      _logger.e('StackTrace: $stackTrace');
      emit(RouteAssignmentState.error('Error inesperado: $e'));
    }
  }

  Future<void> _onMarkWaypointAsVisited(MarkWaypointAsVisited event, Emitter<RouteAssignmentState> emit,) async {
    _logger.i('✅ Marking waypoint as visited: ${event.waypointId}');

    if (_currentRouteId == null) {
      _logger.w('⚠️ Cannot mark waypoint: no current route');
      return;
    }

    try {
      final result = await _routeAssignmentRepository.markWaypointAsVisited(
        event.waypointId,
        _currentRouteId!,
      );

      switch (result) {
        case Success(data: final routeData):
          _logger.i('✅ Waypoint marked as visited successfully');

          emit(RouteAssignmentState.routeAssigned(
            route: routeData.route,
            waypoints: routeData.wayPointsWithContainers,
          ));
          break;

        case Failure(message: final msg):
          _logger.e('❌ Error marking waypoint as visited: $msg');
          emit(RouteAssignmentState.error(msg));
          break;
      }
    } catch (e, stackTrace) {
      _logger.e('💥 Exception in _onMarkWaypointAsVisited: $e');
      _logger.e('StackTrace: $stackTrace');
      emit(RouteAssignmentState.error('Error inesperado: $e'));
    }
  }

  Future<void> _onUpdateDriverLocation(UpdateDriverLocation event, Emitter<RouteAssignmentState> emit,) async {
    if (state is! RouteAssignmentAssigned) {
      return;
    }

    final currentState = state as RouteAssignmentAssigned;

    try {
      await _routeAssignmentRepository.updateDriverLocation(
        currentState.route.id,
        event.latitude,
        event.longitude
      ).then((_) {
        _logger.d('Location sent to backend: ${event.latitude}, ${event.longitude}');
      }).catchError((error) {
        _logger.w('Failed to send location to backend: $error');
      });

    } catch (e) {
      _logger.e('Error updating driver location: $e');
    }
  }
}