import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_container_request.freezed.dart';
part 'update_container_request.g.dart';

@freezed
sealed class UpdateContainerRequest with _$UpdateContainerRequest {
  const factory UpdateContainerRequest({
    String? containerId,
    String? latitude,
    String? longitude,
    int? volumeLiters,
    int? maxWeightKg,
    String? sensorId,
    String? containerType,
    int? collectionFrequencyDays,
  }) = _UpdateContainerRequest;

  factory UpdateContainerRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateContainerRequestFromJson(json);
}
