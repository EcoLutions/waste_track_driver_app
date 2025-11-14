import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/enums/priority_level.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/enums/waypoint_status.dart';

part 'waypoint.freezed.dart';

@freezed
sealed class WayPoint with _$WayPoint {

  const factory WayPoint({
    required String id,
    required String containerId,
    required int sequenceOrder,
    required DateTime createdAt,
    @Default(PriorityLevel.medium) PriorityLevel priority,
    @Default(WayPointStatus.pending) WayPointStatus status,
    DateTime? estimatedArrivalTime,
    DateTime? actualArrivalTime,
    DateTime? updatedAt,
  }) = _WayPoint;
  const WayPoint._();

  bool get isCompleted => status == WayPointStatus.visited;

  bool get isPending => status == WayPointStatus.pending;

  bool get isSkipped => status == WayPointStatus.skipped;

  bool get canBeVisited => status == WayPointStatus.pending;

  bool get hasActualArrival => actualArrivalTime != null;

  bool get hasEstimatedArrival => estimatedArrivalTime != null;

  int? get delayInMinutes {
    if (estimatedArrivalTime == null || actualArrivalTime == null) return null;
    return actualArrivalTime!.difference(estimatedArrivalTime!).inMinutes;
  }

  bool get wasLate {
    final delay = delayInMinutes;
    return delay != null && delay > 0;
  }

  bool get wasEarly {
    final delay = delayInMinutes;
    return delay != null && delay < 0;
  }

  bool get wasOnTime {
    final delay = delayInMinutes;
    if (delay == null) return false;
    return delay.abs() <= 5;
  }

  String get formattedDelay {
    final delay = delayInMinutes;
    if (delay == null) return 'N/A';
    if (delay == 0) return 'On time';
    if (delay > 0) return '+${delay}m late';
    return '${delay.abs()}m early';
  }

  bool get isCriticalPriority => priority == PriorityLevel.critical;

  bool get isHighPriority =>
      priority == PriorityLevel.high || priority == PriorityLevel.critical;

  bool get isOverdue {
    if (estimatedArrivalTime == null || status != WayPointStatus.pending) {
      return false;
    }
    return DateTime.now().isAfter(estimatedArrivalTime!);
  }

  int? get minutesUntilEstimatedArrival {
    if (estimatedArrivalTime == null) return null;
    return estimatedArrivalTime!.difference(DateTime.now()).inMinutes;
  }

  Duration? get timeSpentAtWaypoint {
    if (actualArrivalTime == null) return null;
    return DateTime.now().difference(actualArrivalTime!);
  }
}
