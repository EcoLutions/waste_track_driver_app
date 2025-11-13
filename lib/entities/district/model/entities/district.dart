import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/district/model/enums/operational_status.dart';

part 'district.freezed.dart';

@freezed
sealed class District with _$District {
  const factory District({
    required String id,
    required String name,
    required String code,
    required String boundaries,
    required OperationalStatus operationalStatus,
    required DateTime serviceStartDate,
    required String subscriptionId,
    required int maxVehicles,
    required int maxDrivers,
    required int maxContainers,
    required String primaryAdminEmail,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _District;

  const District._();

  bool get isActive => operationalStatus == OperationalStatus.active;

  bool get isSuspended => operationalStatus == OperationalStatus.suspended;

  bool get isTrial => operationalStatus == OperationalStatus.trial;

  String get statusDisplayName => operationalStatus.displayName;

  bool isWithinServiceLimits(int vehicleCount, int driverCount) {
    return vehicleCount <= maxVehicles && driverCount <= maxDrivers;
  }

  bool get canRegisterNewVehicle => operationalStatus == OperationalStatus.active;

  bool get canRegisterNewDriver => operationalStatus == OperationalStatus.active;
}
