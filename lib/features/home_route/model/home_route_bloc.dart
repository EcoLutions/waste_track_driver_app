import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_event.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_repository.dart';
import 'package:waste_track_driver_app/features/home_route/model/home_route_state.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class HomeRouteBloc extends Bloc<HomeRouteEvent, HomeRouteState> {
  HomeRouteBloc({
    required HomeRouteRepository homeRouteRepository,
  })  : _homeRouteRepository = homeRouteRepository,
        super(const HomeRouteState.initial()) {
    on<LoadActiveRoute>(_onLoadActiveRoute);
    on<RefreshActiveRoute>(_onRefreshActiveRoute);
    on<ClearRoute>(_onClearRoute);
  }

  final HomeRouteRepository _homeRouteRepository;
  final Logger _logger = Logger();

  // ==================== LOAD ACTIVE ROUTE ====================

  Future<void> _onLoadActiveRoute(
      LoadActiveRoute event,
      Emitter<HomeRouteState> emit,
      ) async {
    _logger.i('🏠 [HomeRouteBloc] Loading active route for driver: ${event.driverId}');
    emit(const HomeRouteState.loading());

    try {
      final result = await _homeRouteRepository.getActiveRouteForDriver(
        driverId: event.driverId,
        districtId: event.districtId,
      );

      switch (result) {
        case Success(data: final route):
          if (route == null) {
            // No hay ruta activa - estado válido
            _logger.i('ℹ️ [HomeRouteBloc] No active route found - NotFound state');
            emit(const HomeRouteState.notFound());
          } else {
            // Hay ruta activa
            _logger.i('✅ [HomeRouteBloc] Active route found: ${route.id}');

            // Determinar si tiene waypoints (mirando el totalDistance)
            // Si totalDistance > 0, significa que ya se generaron waypoints
            final hasWaypoints = route.totalDistance > 0;

            _logger.i('📍 [HomeRouteBloc] Route hasWaypoints: $hasWaypoints (distance: ${route.totalDistance}m)');

            emit(HomeRouteState.found(
              route: route,
              hasWaypoints: hasWaypoints,
            ));
          }
          break;

        case Failure(message: final msg):
          _logger.e('❌ [HomeRouteBloc] Error loading route: $msg');
          emit(HomeRouteState.error(msg));
          break;
      }
    } catch (e, stackTrace) {
      _logger.e('💥 [HomeRouteBloc] Exception in _onLoadActiveRoute: $e');
      _logger.e('StackTrace: $stackTrace');
      emit(HomeRouteState.error('Error inesperado: $e'));
    }
  }

  // ==================== REFRESH ACTIVE ROUTE ====================

  Future<void> _onRefreshActiveRoute(
      RefreshActiveRoute event,
      Emitter<HomeRouteState> emit,
      ) async {
    _logger.i('🔄 [HomeRouteBloc] Refreshing active route');

    // No emitir loading si ya estamos en un estado Found
    // Para evitar parpadeo en pull-to-refresh
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
            _logger.i('ℹ️ [HomeRouteBloc] No active route after refresh');
            emit(const HomeRouteState.notFound());
          } else {
            _logger.i('✅ [HomeRouteBloc] Route refreshed: ${route.id}');

            final hasWaypoints = route.totalDistance > 0;

            emit(HomeRouteState.found(
              route: route,
              hasWaypoints: hasWaypoints,
            ));
          }
          break;

        case Failure(message: final msg):
          _logger.e('❌ [HomeRouteBloc] Error refreshing route: $msg');
          emit(HomeRouteState.error(msg));
          break;
      }
    } catch (e, stackTrace) {
      _logger.e('💥 [HomeRouteBloc] Exception in _onRefreshActiveRoute: $e');
      _logger.e('StackTrace: $stackTrace');
      emit(HomeRouteState.error('Error inesperado: $e'));
    }
  }

  // ==================== CLEAR ROUTE ====================

  Future<void> _onClearRoute(
      ClearRoute event,
      Emitter<HomeRouteState> emit,
      ) async {
    _logger.i('🧹 [HomeRouteBloc] Clearing route');
    emit(const HomeRouteState.notFound());
  }
}