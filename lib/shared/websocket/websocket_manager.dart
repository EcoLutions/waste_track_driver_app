import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/websocket/event_bus.dart';
import 'package:waste_track_driver_app/shared/websocket/websocket_events.dart';

enum WebSocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class WebSocketManager {
  factory WebSocketManager() => _instance;
  WebSocketManager._internal();
  static final WebSocketManager _instance = WebSocketManager._internal();

  StompClient? _stompClient;
  WebSocketConnectionStatus _status = WebSocketConnectionStatus.disconnected;
  final Map<String, StompUnsubscribe> _subscriptions = {};
  Timer? _reconnectTimer;
  String? _currentDriverId;

  final _statusController =
  StreamController<WebSocketConnectionStatus>.broadcast();

  Stream<WebSocketConnectionStatus> get statusStream => _statusController.stream;
  WebSocketConnectionStatus get status => _status;

  Future<void> connect() async {
    if (_status == WebSocketConnectionStatus.connected) {
      log('[WebSocket] Already connected');
      return;
    }

    _updateStatus(WebSocketConnectionStatus.connecting);

    try {
      final wsUrl = ApiConstants.wsBaseUrl;

      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onStompError: _onStompError,
          onWebSocketError: _onWebSocketError,
          onDebugMessage: (message) {
            log('[WebSocket] Debug: $message');
          },
          reconnectDelay: const Duration(seconds: 5),
          heartbeatIncoming: const Duration(seconds: 30),
          heartbeatOutgoing: const Duration(seconds: 30),
        ),
      );

      _stompClient!.activate();
      log('[WebSocket] Connecting to: $wsUrl');
    } catch (e) {
      log('[WebSocket] Connection error: $e');
      _updateStatus(WebSocketConnectionStatus.error);
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _clearAllSubscriptions();

    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }

    _updateStatus(WebSocketConnectionStatus.disconnected);
    log('[WebSocket] Disconnected');
  }

  void subscribeToRouteActivations(String driverId) {
    _currentDriverId = driverId;

    if (_status != WebSocketConnectionStatus.connected) {
      log('[WebSocket] Cannot subscribe, not connected');
      return;
    }

    final topic = '/topic/routes/driver/$driverId/activate';
    final subscriptionKey = 'route_activation_$driverId';

    if (_subscriptions.containsKey(subscriptionKey)) {
      log('[WebSocket] Already subscribed to route activations');
      return;
    }

    try {
      final unsubscribe = _stompClient!.subscribe(
        destination: topic,
        callback: (StompFrame frame) {
          _handleRouteActivation(frame);
        },
      );

      _subscriptions[subscriptionKey] = unsubscribe;
      log('[WebSocket] Subscribed to: $topic');
    } catch (e) {
      log('[WebSocket] Error subscribing to route activations: $e');
    }
  }

  void _handleRouteActivation(StompFrame frame) {
    try {
      log('[WebSocket] Route activation received');
      log('[WebSocket] Frame body: ${frame.body}');

      if (frame.body == null) {
        log('[WebSocket] Frame body is null');
        return;
      }

      final jsonData = json.decode(frame.body!) as Map<String, dynamic>;
      log('[WebSocket] Parsed JSON: $jsonData');

      final routeId = jsonData['routeId'] as String?;
      final driverId = jsonData['driverId'] as String?;
      final activatedAtStr = jsonData['activatedAt'] as String?;

      if (routeId == null || driverId == null) {
        log('[WebSocket] Missing required fields in payload');
        return;
      }

      final activatedAt = activatedAtStr != null
          ? DateTime.parse(activatedAtStr)
          : DateTime.now();

      final event = RouteActivated(
        routeId: routeId,
        driverId: driverId,
        activatedAt: activatedAt,
      );

      AppEventBus().emit(event);
      log('[WebSocket] RouteActivated event emitted');
    } catch (e) {
      log('[WebSocket] Error handling route activation: $e');
    }
  }

  void unsubscribeFromRouteActivations() {
    if (_currentDriverId == null) return;

    final subscriptionKey = 'route_activation_$_currentDriverId';

    if (_subscriptions.containsKey(subscriptionKey)) {
      _subscriptions[subscriptionKey]!();
      _subscriptions.remove(subscriptionKey);
      log('[WebSocket] Unsubscribed from route activations');
    }

    _currentDriverId = null;
  }


  void _onConnect(StompFrame frame) {
    log('[WebSocket] Connected');
    _updateStatus(WebSocketConnectionStatus.connected);
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_currentDriverId != null) {
      subscribeToRouteActivations(_currentDriverId!);
    }

    AppEventBus().emit(const WebSocketConnected());
  }

  void _onDisconnect(StompFrame frame) {
    log('[WebSocket] Disconnected');
    _updateStatus(WebSocketConnectionStatus.disconnected);
    _clearAllSubscriptions();
    _scheduleReconnect();

    AppEventBus().emit(const WebSocketDisconnected());
  }

  void _onStompError(StompFrame frame) {
    log('[WebSocket] STOMP Error: ${frame.body}');
    _updateStatus(WebSocketConnectionStatus.error);

    AppEventBus().emit(WebSocketError(frame.body ?? 'Unknown STOMP error'));
  }

  void _onWebSocketError(dynamic error) {
    log('[WebSocket] WebSocket Error: $error');
    _updateStatus(WebSocketConnectionStatus.error);

    AppEventBus().emit(WebSocketError(error.toString()));
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null) return;

    _updateStatus(WebSocketConnectionStatus.reconnecting);

    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      log('[WebSocket] Attempting to reconnect...');
      connect();
      _reconnectTimer = null;
    });
  }

  void _updateStatus(WebSocketConnectionStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
    log('[WebSocket] Status changed to: $newStatus');
  }

  void _clearAllSubscriptions() {
    for (final unsubscribe in _subscriptions.values) {
      unsubscribe();
    }
    _subscriptions.clear();
    log('[WebSocket] Cleared all subscriptions');
  }

  void dispose() {
    disconnect();
    _statusController.close();
  }
}