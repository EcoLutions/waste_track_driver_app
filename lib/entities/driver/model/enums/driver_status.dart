import 'package:freezed_annotation/freezed_annotation.dart';

enum DriverStatus {
  @JsonValue('AVAILABLE')
  available,

  @JsonValue('ON_ROUTE')
  onRoute,

  @JsonValue('OFF_DUTY')
  offDuty,

  @JsonValue('SUSPENDED')
  suspended;

  String get displayName {
    switch (this) {
      case DriverStatus.available:
        return 'Disponible';
      case DriverStatus.onRoute:
        return 'En Ruta';
      case DriverStatus.offDuty:
        return 'Fuera de Servicio';
      case DriverStatus.suspended:
        return 'Suspendido';
    }
  }
}

extension DriverStatusExtension on DriverStatus {
  String toJson() {
    switch (this) {
      case DriverStatus.available:
        return 'AVAILABLE';
      case DriverStatus.onRoute:
        return 'ON_ROUTE';
      case DriverStatus.offDuty:
        return 'OFF_DUTY';
      case DriverStatus.suspended:
        return 'SUSPENDED';
    }
  }

  static DriverStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return DriverStatus.available;
      case 'ON_ROUTE':
        return DriverStatus.onRoute;
      case 'OFF_DUTY':
        return DriverStatus.offDuty;
      case 'SUSPENDED':
        return DriverStatus.suspended;
      default:
        throw ArgumentError('Unknown status: $status');
    }
  }
}
