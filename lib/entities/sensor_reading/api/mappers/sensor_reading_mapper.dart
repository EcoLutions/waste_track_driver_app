import 'package:waste_track_driver_app/entities/sensor_reading/api/dto/create_sensor_reading_request.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/api/dto/sensor_reading_response.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/api/dto/update_sensor_reading_request.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/api/mappers/sensor_reading_enum_mapper.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/model/entities/sensor_reading.dart';

extension SensorReadingResponseMapper on SensorReadingResponse {
  SensorReading toDomain() {
    return SensorReading(
      id: id ?? '',
      containerId: containerId ?? '',
      fillLevelPercentage: fillLevelPercentage ?? 0,
      temperatureCelsius: _parseDouble(temperatureCelsius),
      batteryLevelPercentage: batteryLevelPercentage ?? 0,
      validationStatus: ValidationStatusMapper.parse(validationStatus),
      recordedAt: _parseDate(recordedAt),
      receivedAt: _parseDate(receivedAt),
      createdAt: _parseDate(createdAt),
      updatedAt: _parseDateOrNull(updatedAt),
    );
  }

  DateTime _parseDate(String? date) {
    if (date == null || date.isEmpty) {
      return DateTime(0);
    }

    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime(0);
    }
  }

  DateTime? _parseDateOrNull(String? date) {
    if (date == null || date.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }

  double _parseDouble(String? value) {
    if (value == null || value.isEmpty) {
      return 0.0;
    }

    try {
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }
}

extension SensorReadingToCreateRequestMapper on SensorReading {
  CreateSensorReadingRequest toCreateRequest() {
    return CreateSensorReadingRequest(
      containerId: containerId,
      fillLevelPercentage: fillLevelPercentage,
      temperatureCelsius: temperatureCelsius,
      batteryLevelPercentage: batteryLevelPercentage,
    );
  }
}

extension SensorReadingToUpdateRequestMapper on SensorReading {
  UpdateSensorReadingRequest toUpdateRequest() {
    return UpdateSensorReadingRequest(
      containerId: containerId,
      fillLevelPercentage: fillLevelPercentage,
      temperatureCelsius: temperatureCelsius,
      batteryLevelPercentage: batteryLevelPercentage,
    );
  }
}
