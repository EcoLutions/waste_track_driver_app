import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/driver/model/enums/driver_status.dart';

part 'driver.freezed.dart';

@freezed
sealed class Driver with _$Driver {
  const factory Driver({
    required String id,
    required String districtId,
    required String firstName,
    required String lastName,
    required String documentNumber,
    required String phoneNumber,
    required String userId,
    required String driverLicense,
    required DateTime licenseExpiryDate,
    required String emailAddress,
    required int totalHoursWorked,
    required DriverStatus status,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? lastRouteCompletedAt,
  }) = _Driver;

  const Driver._();

  String get fullName => '$firstName $lastName';

  bool get isAvailable => status == DriverStatus.available;

  bool get isOnRoute => status == DriverStatus.onRoute;

  bool get isOffDuty => status == DriverStatus.offDuty;

  bool get isSuspended => status == DriverStatus.suspended;

  String get statusDisplayName => status.displayName;

  bool get isLicenseExpired => DateTime.now().isAfter(licenseExpiryDate);

  bool get isAvailableForNewRoute => isAvailable && !isLicenseExpired;

  bool get hasCompletedRoutes => lastRouteCompletedAt != null;

  int get daysUntilLicenseExpiry {
    final now = DateTime.now();
    if (licenseExpiryDate.isBefore(now)) return 0;
    return licenseExpiryDate.difference(now).inDays;
  }

  bool get isLicenseExpiringSoon => daysUntilLicenseExpiry <= 30 && daysUntilLicenseExpiry > 0;
}
