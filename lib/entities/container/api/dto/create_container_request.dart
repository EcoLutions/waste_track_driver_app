import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_container_request.freezed.dart';
part 'create_container_request.g.dart';

@freezed
sealed class CreateContainerRequest with _$CreateContainerRequest {
  const factory CreateContainerRequest({
    String? latitude,
    String? longitude,
    int? volumeLiters,
    int? maxWeightKg,
    String? sensorId,
    String? containerType,
    String? districtId,
    int? collectionFrequencyDays,
  }) = _CreateContainerRequest;

  factory CreateContainerRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateContainerRequestFromJson(json);
}
