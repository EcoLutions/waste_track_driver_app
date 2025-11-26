import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/container/model/enums/container_status.dart';
import 'package:waste_track_driver_app/entities/container/model/enums/container_type.dart';

part 'container.freezed.dart';

@freezed
sealed class Container with _$Container {

  const factory Container({
    required String id,
    required double latitude,
    required double longitude,
    required int volumeLiters,
    required int maxWeightKg,
    required ContainerType containerType,
    required ContainerStatus status,
    required String districtId,
    required int collectionFrequencyDays,
    required DateTime createdAt,
    @Default(0) int currentFillLevel,
    String? sensorId,
    DateTime? lastReadingTimestamp,
    DateTime? lastCollectionDate,
    DateTime? updatedAt,
  }) = _Container;
  const Container._();

  double get fillPercentage {
    // currentFillLevel ya viene en porcentaje desde el backend
    return currentFillLevel.toDouble();
  }

  bool get requiresCollection {
    if (fillPercentage >= 90) return true;

    if (lastCollectionDate == null) {
      return fillPercentage >= 75;
    }

    final nextCollectionDate =
        lastCollectionDate!.add(Duration(days: collectionFrequencyDays));
    return DateTime.now().isAfter(nextCollectionDate) || fillPercentage >= 75;
  }

  bool get isOverflowing => fillPercentage >= 100;

  bool get isCritical => fillPercentage >= 90;

  bool get isActive => status == ContainerStatus.active;

  bool get isInMaintenance => status == ContainerStatus.maintenance;

  bool get isDecommissioned => status == ContainerStatus.decommissioned;

  bool get hasSensor => sensorId != null && sensorId!.isNotEmpty;

  int? get daysSinceLastCollection {
    if (lastCollectionDate == null) return null;
    return DateTime.now().difference(lastCollectionDate!).inDays;
  }

  int? get daysUntilNextCollection {
    if (lastCollectionDate == null) return null;
    final nextCollectionDate =
        lastCollectionDate!.add(Duration(days: collectionFrequencyDays));
    final daysUntil = nextCollectionDate.difference(DateTime.now()).inDays;
    return daysUntil > 0 ? daysUntil : 0;
  }

  bool get isCollectionOverdue {
    if (lastCollectionDate == null) return false;
    final nextCollectionDate =
        lastCollectionDate!.add(Duration(days: collectionFrequencyDays));
    return DateTime.now().isAfter(nextCollectionDate);
  }

  int get collectionPriority {
    if (isOverflowing) return 5;
    if (isCritical) return 4;
    if (isCollectionOverdue) return 3;
    if (fillPercentage >= 75) return 2;
    return 1;
  }

  bool hasBecomeCritical(int previousFillLevel) {
    final previousPercentage = (previousFillLevel / volumeLiters) * 100;
    final wasCritical = previousPercentage >= 90;
    return !wasCritical && isCritical;
  }

  String get formattedCapacity => '$volumeLiters L / $maxWeightKg kg';

  String get formattedFillLevel =>
      '$currentFillLevel L (${fillPercentage.toStringAsFixed(1)}%)';

  int get remainingCapacity {
    final remaining = volumeLiters - currentFillLevel;
    return remaining > 0 ? remaining : 0;
  }
}
