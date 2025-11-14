import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_response.freezed.dart';
part 'driver_response.g.dart';

@freezed
sealed class DriverResponse with _$DriverResponse {
  const factory DriverResponse({
    String? id,
    String? districtId,
    String? firstName,
    String? lastName,
    String? documentNumber,
    String? phoneNumber,
    String? userId,
    String? driverLicense,
    String? licenseExpiryDate,
    String? emailAddress,
    int? totalHoursWorked,
    String? lastRouteCompletedAt,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) = _DriverResponse;

  factory DriverResponse.fromJson(Map<String, dynamic> json) =>
      _$DriverResponseFromJson(json);
}
