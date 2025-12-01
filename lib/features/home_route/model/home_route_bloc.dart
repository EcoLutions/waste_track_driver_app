import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_event.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_repository.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_state.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';
import 'package:waste_track_driver_app/shared/websocket/event_bus.dart';
import 'package:waste_track_driver_app/shared/websocket/websocket_events.dart';
import 'package:waste_track_driver_app/shared/websocket/websocket_manager.dart';

class HomeRouteBloc extends Bloc<HomeRouteEvent, HomeRouteState> {
  HomeRouteBloc({
    required HomeRouteRepository homeRouteRepository,
  })  : _homeRouteRepository = homeRouteRepository,
        super(const HomeRouteState.initial()) {
    on<LoadActiveRoute>(_onLoadActiveRoute);
    on<RefreshActiveRoute>(_onRefreshActiveRoute);
    on<ClearRoute>(_onClearRoute);
    on<RouteActivatedFromWebSocket>(_onRouteActivatedFromWebSocket);

    _webSocketSubscription = AppEventBus().on<RouteActivated>().listen(
          (event) {
        _logger.i('🔔 [HomeRouteBloc] RouteActivated event received: ${event.routeId}');
        add(RouteActivatedFromWebSocket(
          routeId: event.routeId,
          driverId: event.driverId,
        ));
      },
    );
  }

  final HomeRouteRepository _homeRouteRepository;
  final Logger _logger = Logger();

  StreamSubscription<RouteActivated>? _webSocketSubscription;
  String? _currentDriverId;
  String? _currentDistrictId;

  // ==================== LOAD ACTIVE ROUTE ====================

  Future<void> _onLoadActiveRoute(
      LoadActiveRoute event,
      Emitter<HomeRouteState> emit,
      ) async {
    _logger.i('[HomeRouteBloc] Loading active route for driver: ${event.driverId}');

    _currentDriverId = event.driverId;
    _currentDistrictId = event.districtId;

    emit(const HomeRouteState.loading());

    try {
      final result = await _homeRouteRepository.getActiveRouteForDriver(
        driverId: event.driverId,
        districtId: event.districtId,
      );

      switch (result) {
        case Success(data: final route):
          if (route == null) {
            _logger.i('ℹ[HomeRouteBloc] No active route found - Starting WebSocket listener');
            _startWebSocketListener(event.driverId);
            emit(const HomeRouteState.notFound());
          } else {
            _logger.i('[HomeRouteBloc] Active route found: ${route.id}');
            _stopWebSocketListener();

            final hasWaypoints = route.totalDistance > 0;

            _logger.i('[HomeRouteBloc] Route hasWaypoints: $hasWaypoints (distance: ${route.totalDistance}m)');

            emit(HomeRouteState.found(
              route: route,
              hasWaypoints: hasWaypoints,
            ));
          }
          break;

        case Failure(message: final msg):
          _logger.e('[HomeRouteBloc] Error loading route: $msg');
          emit(HomeRouteState.error(msg));
          break;
      }
    } catch (e, stackTrace) {
      _logger.e('[HomeRouteBloc] Exception in _onLoadActiveRoute: $e');
      _logger.e('StackTrace: $stackTrace');
      emit(HomeRouteState.error('Error inesperado: $e'));
    }
  }

  // ==================== REFRESH ACTIVE ROUTE ====================

  Future<void> _onRefreshActiveRoute(
      RefreshActiveRoute event,
      Emitter<HomeRouteState> emit,
      ) async {
    _logger.i('[HomeRouteBloc] Refreshing active route');

    _currentDriverId = event.driverId;
    _currentDistrictId = event.districtId;

    final shouldShowLoading = state is! HomeRouteFound;

    if (shouldShowLoading) {
      emit(const HomeRouteState.loading());
    }

    try {
      final result = await _homeRouteRepository.getActiveRouteForDriver(
        driverId: event.driverId,
        districtId: event.districtId,
      );

      switch (result) {
        case Success(data: final route):
          if (route == null) {
            _logger.i('[HomeRouteBloc] No active route after refresh - Starting WebSocket');
            _startWebSocketListener(event.driverId);
            emit(const HomeRouteState.notFound());
          } else {
            _logger.i('[HomeRouteBloc] Route refreshed: ${route.id}');
            _stopWebSocketListener();

            final hasWaypoints = route.totalDistance > 0;

            emit(HomeRouteState.found(
              route: route,
              hasWaypoints: hasWaypoints,
            ));
          }
          break;

        case Failure(message: final msg):
          _logger.e('[HomeRouteBloc] Error refreshing route: $msg');
          emit(HomeRouteState.error(msg));
          break;
      }
    } catch (e, stackTrace) {
      _logger.e('[HomeRouteBloc] Exception in _onRefreshActiveRoute: $e');
      _logger.e('StackTrace: $stackTrace');
      emit(HomeRouteState.error('Error inesperado: $e'));
    }
  }

  // ==================== ROUTE ACTIVATED FROM WEBSOCKET ====================

  Future<void> _onRouteActivatedFromWebSocket(
      RouteActivatedFromWebSocket event,
      Emitter<HomeRouteState> emit,
      ) async {
    _logger.i('[HomeRouteBloc] Processing RouteActivated from WebSocket: ${event.routeId}');

    // Verificar que el evento es para el driver correcto
    if (event.driverId != _currentDriverId) {
      _logger.w('[HomeRouteBloc] RouteActivated for different driver, ignoring');
      return;
    }

    // Solo recargar si estamos en estado NotFound
    if (state is! HomeRouteNotFound) {
      _logger.i('[HomeRouteBloc] Already have a route, ignoring WebSocket event');
      return;
    }

    _logger.i('[HomeRouteBloc] Reloading route due to WebSocket activation');

    // Recargar la ruta
    if (_currentDriverId != null && _currentDistrictId != null) {
      add(RefreshActiveRoute(
        driverId: _currentDriverId!,
        districtId: _currentDistrictId!,
      ));
    }
  }

  // ==================== CLEAR ROUTE ====================

  Future<void> _onClearRoute(
      ClearRoute event,
      Emitter<HomeRouteState> emit,
      ) async {
    _logger.i('[HomeRouteBloc] Clearing route');
    _stopWebSocketListener();
    emit(const HomeRouteState.notFound());
  }

  // ==================== WEBSOCKET MANAGEMENT ====================

  void _startWebSocketListener(String driverId) {
    _logger.i('[HomeRouteBloc] Starting WebSocket listener for driver: $driverId');

    final wsManager = WebSocketManager();

    // Conectar si no está conectado
    if (wsManager.status != WebSocketConnectionStatus.connected) {
      wsManager.connect();
    }

    // Suscribirse a activaciones de ruta
    wsManager.subscribeToRouteActivations(driverId);
  }

  void _stopWebSocketListener() {
    _logger.i('[HomeRouteBloc] Stopping WebSocket listener');

    final wsManager = WebSocketManager();
    wsManager.unsubscribeFromRouteActivations();

    // Opcionalmente desconectar (si no hay otras suscripciones activas)
    // wsManager.disconnect();
  }

  @override
  Future<void> close() {
    _stopWebSocketListener();
    _webSocketSubscription?.cancel();
    return super.close();
  }
}