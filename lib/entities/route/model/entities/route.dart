import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/route/model/enums/route_status.dart';

part 'route.freezed.dart';

@freezed
sealed class Route with _$Route {
  const factory Route({
    required String id,
    required String districtId,
    required String vehicleId,
    required String driverId,
    required RouteStatus status,
    required int totalWaypoints,
    required int totalCompletedWaypoints,
    required DateTime scheduledStartAt,
    required DateTime createdAt,
    @Default(0.0) double totalDistance,
    @Default(Duration.zero) Duration estimatedDuration,
    @Default(Duration.zero) Duration collectionDuration,
    @Default(Duration.zero) Duration returnDuration,
    @Default(Duration.zero) Duration actualDuration,
    DateTime? scheduledEndAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastLocationUpdate,
    DateTime? updatedAt,
  }) = _Route;
  const Route._();

  bool get canBeModified => status == RouteStatus.planned;

  bool get isOverdue {
    if (status == RouteStatus.completed || status == RouteStatus.cancelled) {
      return false;
    }
    return DateTime.now().isAfter(scheduledStartAt);
  }

  bool get isInProgress => status == RouteStatus.inProgress;

  bool get isCompleted => status == RouteStatus.completed;

  bool get isCancelled => status == RouteStatus.cancelled;

  bool get hasCurrentLocation =>
      currentLatitude != null && currentLongitude != null;

  bool get hasStarted => startedAt != null;

  bool get hasCompleted => completedAt != null;

  DateTime? get estimatedDisposalArrival {
    if (collectionDuration == Duration.zero) return null;
    return scheduledStartAt.add(collectionDuration);
  }

  DateTime? get estimatedDepotReturn {
    if (estimatedDuration == Duration.zero) return null;
    return scheduledStartAt.add(estimatedDuration);
  }

  bool isWithinTimeConstraint(Duration maxDuration) {
    if (estimatedDuration == Duration.zero) return true;
    return estimatedDuration <= maxDuration;
  }

  String get formattedTotalDistance {
    if (totalDistance < 1.0) {
      return '${(totalDistance * 1000).toStringAsFixed(0)} m';
    }
    return '${totalDistance.toStringAsFixed(2)} km';
  }

  String get formattedEstimatedDuration {
    final hours = estimatedDuration.inHours;
    final minutes = estimatedDuration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedActualDuration {
    if (actualDuration == Duration.zero) return 'N/A';
    final hours = actualDuration.inHours;
    final minutes = actualDuration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  bool get isLateCompletion {
    if (completedAt == null || estimatedDuration == Duration.zero) {
      return false;
    }
    final expectedCompletion = scheduledStartAt.add(estimatedDuration);
    return completedAt!.isAfter(expectedCompletion);
  }

  Duration? get delayDuration {
    if (!isLateCompletion || completedAt == null) return null;
    final expectedCompletion = scheduledStartAt.add(estimatedDuration);
    return completedAt!.difference(expectedCompletion);
  }
}
