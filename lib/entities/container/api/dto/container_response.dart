import 'package:freezed_annotation/freezed_annotation.dart';

part 'container_response.freezed.dart';
part 'container_response.g.dart';

@freezed
sealed class ContainerResponse with _$ContainerResponse {
  const factory ContainerResponse({
    String? id,
    String? latitude,
    String? longitude,
    int? volumeLiters,
    int? maxWeightKg,
    String? containerType,
    String? status,
    int? currentFillLevel,
    String? sensorId,
    String? lastReadingTimestamp,
    String? districtId,
    String? lastCollectionDate,
    int? collectionFrequencyDays,
    String? createdAt,
    String? updatedAt,
  }) = _ContainerResponse;

  factory ContainerResponse.fromJson(Map<String, dynamic> json) =>
      _$ContainerResponseFromJson(json);
}
