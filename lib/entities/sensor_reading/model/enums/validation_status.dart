enum ValidationStatus {
  valid,
  anomaly,
  sensorError;

  String get displayName => switch (this) {
        ValidationStatus.valid => 'Valid',
        ValidationStatus.anomaly => 'Anomaly',
        ValidationStatus.sensorError => 'Sensor Error',
      };
}
