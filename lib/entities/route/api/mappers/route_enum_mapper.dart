import 'package:waste_track_driver_app/entities/route/model/enums/route_status.dart';
import 'package:waste_track_driver_app/entities/route/model/enums/route_type.dart';

class RouteTypeMapper {
  static RouteType parse(String? value) {
    return switch (value?.toUpperCase()) {
      'REGULAR' => RouteType.regular,
      'EMERGENCY' => RouteType.emergency,
      'OPTIMIZED' => RouteType.optimized,
      _ => RouteType.regular,
    };
  }

  static String toDto(RouteType type) {
    return switch (type) {
      RouteType.regular => 'REGULAR',
      RouteType.emergency => 'EMERGENCY',
      RouteType.optimized => 'OPTIMIZED',
    };
  }
}

class RouteStatusMapper {
  static RouteStatus parse(String? value) {
    return switch (value?.toUpperCase()) {
      'ASSIGNED' => RouteStatus.assigned,
      'IN_PROGRESS' => RouteStatus.inProgress,
      'COMPLETED' => RouteStatus.completed,
      'CANCELLED' => RouteStatus.cancelled,
      _ => RouteStatus.assigned,
    };
  }

  static String toDto(RouteStatus status) {
    return switch (status) {
      RouteStatus.assigned => 'ASSIGNED',
      RouteStatus.inProgress => 'IN_PROGRESS',
      RouteStatus.completed => 'COMPLETED',
      RouteStatus.cancelled => 'CANCELLED',
    };
  }
}
