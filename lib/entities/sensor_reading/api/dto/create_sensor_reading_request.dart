import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_sensor_reading_request.freezed.dart';
part 'create_sensor_reading_request.g.dart';

@freezed
sealed class CreateSensorReadingRequest with _$CreateSensorReadingRequest {
  const factory CreateSensorReadingRequest({
    String? containerId,
    int? fillLevelPercentage,
    double? temperatureCelsius,
    int? batteryLevelPercentage,
  }) = _CreateSensorReadingRequest;

  factory CreateSensorReadingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSensorReadingRequestFromJson(json);
}
