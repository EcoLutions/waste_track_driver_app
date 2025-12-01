import 'dart:async';
import 'dart:developer';

import 'package:waste_track_driver_app/shared/websocket/websocket_events.dart';

class AppEventBus {
  factory AppEventBus() => _instance;
  AppEventBus._internal();
  static final AppEventBus _instance = AppEventBus._internal();

  final StreamController<AppEvent> _controller =
  StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get events => _controller.stream;

  Stream<T> on<T extends AppEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  void emit(AppEvent event) {
    log('[EventBus] Emitting: ${event.runtimeType}');
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}