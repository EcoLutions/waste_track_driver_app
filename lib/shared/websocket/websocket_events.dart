import 'package:equatable/equatable.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';

/// Eventos base
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

// ========== EVENTOS DE WEBSOCKET ==========

/// WebSocket conectado
class WebSocketConnected extends AppEvent {
  const WebSocketConnected();
}

/// WebSocket desconectado
class WebSocketDisconnected extends AppEvent {
  const WebSocketDisconnected();
}

/// Error en WebSocket
class WebSocketError extends AppEvent {
  const WebSocketError(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}

// ========== EVENTOS DE RUTAS ==========

/// Ruta activada (recibida del backend)
class RouteActivated extends AppEvent {

  const RouteActivated({
    required this.routeId,
    required this.driverId,
    required this.activatedAt,
  });
  final String routeId;
  final String driverId;
  final DateTime activatedAt;

  @override
  List<Object?> get props => [routeId, driverId, activatedAt];
}

/// Ruta actualizada
class RouteUpdated extends AppEvent {

  const RouteUpdated(this.route);
  final Route route;

  @override
  List<Object?> get props => [route];
}

/// Waypoint completado
class WaypointCompleted extends AppEvent {

  const WaypointCompleted({
    required this.waypointId,
    required this.routeId,
  });
  final String waypointId;
  final String routeId;

  @override
  List<Object?> get props => [waypointId, routeId];
}