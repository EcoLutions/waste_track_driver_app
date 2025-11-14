import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_vehicle_request.freezed.dart';
part 'update_vehicle_request.g.dart';

@freezed
sealed class UpdateVehicleRequest with _$UpdateVehicleRequest {
  const factory UpdateVehicleRequest({
    String? vehicleId,
    String? licensePlate,
    String? vehicleType,
    double? volumeCapacity,
    double? weightCapacity,
    String? lastMaintenanceDate,
    String? nextMaintenanceDate,
    bool? isActive,
  }) = _UpdateVehicleRequest;

  factory UpdateVehicleRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateVehicleRequestFromJson(json);
}
