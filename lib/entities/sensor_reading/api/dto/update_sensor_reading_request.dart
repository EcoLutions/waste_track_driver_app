import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_sensor_reading_request.freezed.dart';
part 'update_sensor_reading_request.g.dart';

@freezed
sealed class UpdateSensorReadingRequest with _$UpdateSensorReadingRequest {
  const factory UpdateSensorReadingRequest({
    String? containerId,
    int? fillLevelPercentage,
    double? temperatureCelsius,
    int? batteryLevelPercentage,
  }) = _UpdateSensorReadingRequest;

  factory UpdateSensorReadingRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSensorReadingRequestFromJson(json);
}
