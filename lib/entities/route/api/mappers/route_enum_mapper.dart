import 'package:waste_track_driver_app/entities/route/model/enums/route_status.dart';

class RouteStatusMapper {
  static RouteStatus parse(String? value) {
    return switch (value?.toUpperCase()) {
      'PLANNED' => RouteStatus.planned,
      'ACTIVE' => RouteStatus.active,
      'IN_PROGRESS' => RouteStatus.inProgress,
      'COMPLETED' => RouteStatus.completed,
      'CANCELLED' => RouteStatus.cancelled,
      _ => RouteStatus.planned,
    };
  }

  static String toDto(RouteStatus status) {
    return switch (status) {
      RouteStatus.planned => 'PLANNED',
      RouteStatus.active => 'ACTIVE',
      RouteStatus.inProgress => 'IN_PROGRESS',
      RouteStatus.completed => 'COMPLETED',
      RouteStatus.cancelled => 'CANCELLED',
    };
  }
}
