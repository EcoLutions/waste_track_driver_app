import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_response.freezed.dart';
part 'vehicle_response.g.dart';

@freezed
sealed class VehicleResponse with _$VehicleResponse {
  const factory VehicleResponse({
    String? id,
    String? licensePlate,
    String? vehicleType,
    String? volumeCapacity,
    int? weightCapacity,
    int? mileage,
    String? districtId,
    String? lastMaintenanceDate,
    String? nextMaintenanceDate,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) = _VehicleResponse;

  factory VehicleResponse.fromJson(Map<String, dynamic> json) =>
      _$VehicleResponseFromJson(json);
}
