import 'package:waste_track_driver_app/entities/waypoint/model/enums/priority_level.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/enums/waypoint_status.dart';

class PriorityLevelMapper {
  static PriorityLevel parse(String? value) {
    return switch (value?.toUpperCase()) {
      'LOW' => PriorityLevel.low,
      'MEDIUM' => PriorityLevel.medium,
      'HIGH' => PriorityLevel.high,
      'CRITICAL' => PriorityLevel.critical,
      _ => PriorityLevel.medium,
    };
  }

  static String toDto(PriorityLevel level) {
    return switch (level) {
      PriorityLevel.low => 'LOW',
      PriorityLevel.medium => 'MEDIUM',
      PriorityLevel.high => 'HIGH',
      PriorityLevel.critical => 'CRITICAL',
    };
  }
}

class WayPointStatusMapper {
  static WayPointStatus parse(String? value) {
    return switch (value?.toUpperCase()) {
      'PENDING' => WayPointStatus.pending,
      'VISITED' => WayPointStatus.visited,
      'SKIPPED' => WayPointStatus.skipped,
      _ => WayPointStatus.pending,
    };
  }

  static String toDto(WayPointStatus status) {
    return switch (status) {
      WayPointStatus.pending => 'PENDING',
      WayPointStatus.visited => 'VISITED',
      WayPointStatus.skipped => 'SKIPPED',
    };
  }
}
