import 'package:freezed_annotation/freezed_annotation.dart';

part 'sensor_reading_response.freezed.dart';
part 'sensor_reading_response.g.dart';

@freezed
sealed class SensorReadingResponse with _$SensorReadingResponse {
  const factory SensorReadingResponse({
    String? id,
    String? containerId,
    int? fillLevelPercentage,
    String? temperatureCelsius,
    int? batteryLevelPercentage,
    String? validationStatus,
    String? recordedAt,
    String? receivedAt,
    String? createdAt,
    String? updatedAt,
  }) = _SensorReadingResponse;

  factory SensorReadingResponse.fromJson(Map<String, dynamic> json) =>
      _$SensorReadingResponseFromJson(json);
}
