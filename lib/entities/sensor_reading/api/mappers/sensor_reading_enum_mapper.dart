import 'package:waste_track_driver_app/entities/sensor_reading/model/enums/validation_status.dart';

class ValidationStatusMapper {
  static ValidationStatus parse(String? value) {
    return switch (value?.toUpperCase()) {
      'VALID' => ValidationStatus.valid,
      'ANOMALY' => ValidationStatus.anomaly,
      'SENSOR_ERROR' => ValidationStatus.sensorError,
      _ => ValidationStatus.valid,
    };
  }

  static String toDto(ValidationStatus status) {
    return switch (status) {
      ValidationStatus.valid => 'VALID',
      ValidationStatus.anomaly => 'ANOMALY',
      ValidationStatus.sensorError => 'SENSOR_ERROR',
    };
  }
}
