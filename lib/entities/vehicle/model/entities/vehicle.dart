import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/vehicle/model/enums/vehicle_type.dart';

part 'vehicle.freezed.dart';

@freezed
sealed class Vehicle with _$Vehicle {

  const factory Vehicle({
    required String id,
    required String licensePlate,
    required VehicleType vehicleType,
    required String districtId,
    required DateTime createdAt,
    @Default(0.0) double volumeCapacity,
    @Default(0) int weightCapacity,
    @Default(0) int mileage,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    @Default(true) bool isActive,
    DateTime? updatedAt,
  }) = _Vehicle;
  const Vehicle._();

  static const int maintenanceIntervalKm = 10000;

  bool get isAvailable => isActive;

  bool get needsMaintenanceByMileage => mileage >= maintenanceIntervalKm;

  bool get needsMaintenance {
    if (nextMaintenanceDate != null) {
      final now = DateTime.now();
      return now.isAfter(nextMaintenanceDate!) || needsMaintenanceByMileage;
    }
    return needsMaintenanceByMileage;
  }

  bool get isMaintenanceOverdue {
    if (nextMaintenanceDate == null) return false;
    return DateTime.now().isAfter(nextMaintenanceDate!);
  }

  int? get daysUntilNextMaintenance {
    if (nextMaintenanceDate == null) return null;
    return nextMaintenanceDate!.difference(DateTime.now()).inDays;
  }

  int? get daysSinceLastMaintenance {
    if (lastMaintenanceDate == null) return null;
    return DateTime.now().difference(lastMaintenanceDate!).inDays;
  }

  int get kilometersUntilNextMaintenance {
    final remaining = maintenanceIntervalKm - (mileage % maintenanceIntervalKm);
    return remaining > 0 ? remaining : 0;
  }

  String get formattedVolumeCapacity => '${volumeCapacity.toStringAsFixed(2)} m³';

  String get formattedWeightCapacity => '$weightCapacity kg';

  String get formattedMileage => '$mileage km';

  bool get isInactive => !isActive;

  String get maintenanceStatus {
    if (isMaintenanceOverdue) return 'Overdue';
    if (needsMaintenanceByMileage) return 'Due by mileage';
    if (nextMaintenanceDate != null) {
      final days = daysUntilNextMaintenance!;
      if (days <= 7) return 'Due soon';
      return 'Scheduled';
    }
    return 'Not scheduled';
  }

  String get typeCategory => switch (vehicleType) {
        VehicleType.compactor => 'Heavy duty compactor truck',
        VehicleType.truck => 'Standard collection truck',
        VehicleType.miniTruck => 'Compact collection vehicle',
      };

  double get maintenanceProgressPercentage {
    final currentCycle = mileage % maintenanceIntervalKm;
    return (currentCycle / maintenanceIntervalKm) * 100;
  }

  bool get isApproachingMaintenance => maintenanceProgressPercentage >= 80;
}
