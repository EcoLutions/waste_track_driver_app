import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/model/enums/validation_status.dart';

part 'sensor_reading.freezed.dart';

@freezed
sealed class SensorReading with _$SensorReading {

  const factory SensorReading({
    required String id,
    required String containerId,
    required DateTime recordedAt,
    required DateTime receivedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(0) int fillLevelPercentage,
    @Default(0.0) double temperatureCelsius,
    @Default(0) int batteryLevelPercentage,
    @Default(ValidationStatus.valid) ValidationStatus validationStatus,
  }) = _SensorReading;
  const SensorReading._();

  bool get isValid => validationStatus == ValidationStatus.valid;

  bool get isAnomaly => validationStatus == ValidationStatus.anomaly;

  bool get hasSensorError => validationStatus == ValidationStatus.sensorError;

  bool get isFillLevelValid => fillLevelPercentage >= 0 && fillLevelPercentage <= 100;

  bool get batteryRequiresReplacement => batteryLevelPercentage < 20;

  bool get isBatteryLow => batteryLevelPercentage < 30;

  bool get isBatteryCritical => batteryLevelPercentage < 10;

  bool get isTemperatureNormal => temperatureCelsius >= -30 && temperatureCelsius <= 80;

  bool get requiresMaintenance => batteryRequiresReplacement || hasSensorError;

  Duration get processingDelay => receivedAt.difference(recordedAt);

  bool get hasProcessingDelay => processingDelay.inMinutes > 5;

  String get fillLevelSeverity {
    if (fillLevelPercentage >= 90) return 'Critical';
    if (fillLevelPercentage >= 75) return 'High';
    if (fillLevelPercentage >= 50) return 'Medium';
    return 'Low';
  }

  String get batteryLevelSeverity {
    if (batteryLevelPercentage < 10) return 'Critical';
    if (batteryLevelPercentage < 20) return 'Low';
    if (batteryLevelPercentage < 50) return 'Medium';
    return 'High';
  }

  String get temperatureSeverity {
    if (temperatureCelsius < -30 || temperatureCelsius > 80) return 'Error';
    if (temperatureCelsius < -10 || temperatureCelsius > 60) return 'Warning';
    return 'Normal';
  }

  String get formattedTemperature =>
      '${temperatureCelsius.toStringAsFixed(1)}°C';

  String get formattedFillLevel => '$fillLevelPercentage%';

  String get formattedBatteryLevel => '$batteryLevelPercentage%';

  bool get isContainerNearlyFull => fillLevelPercentage >= 75;

  bool get isContainerFull => fillLevelPercentage >= 90;

  int get ageInMinutes => DateTime.now().difference(recordedAt).inMinutes;

  bool get isRecent => ageInMinutes < 60;

  bool get isStale => ageInMinutes > 1440;
}
