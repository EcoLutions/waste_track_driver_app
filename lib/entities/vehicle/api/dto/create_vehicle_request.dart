import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_vehicle_request.freezed.dart';
part 'create_vehicle_request.g.dart';

@freezed
sealed class CreateVehicleRequest with _$CreateVehicleRequest {
  const factory CreateVehicleRequest({
    String? licensePlate,
    String? vehicleType,
    String? volumeCapacity,
    String? weightCapacity,
    String? districtId,
  }) = _CreateVehicleRequest;

  factory CreateVehicleRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateVehicleRequestFromJson(json);
}
