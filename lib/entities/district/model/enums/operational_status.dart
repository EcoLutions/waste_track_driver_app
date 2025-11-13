import 'package:freezed_annotation/freezed_annotation.dart';

enum OperationalStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('TRIAL')
  trial;
  String get displayName {
    switch (this) {
      case OperationalStatus.active:
        return 'Activo';
      case OperationalStatus.suspended:
        return 'Suspendido';
      case OperationalStatus.trial:
        return 'Prueba';
    }
  }
}

extension OperationalStatusExtension on OperationalStatus {
  String toJson() {
    switch (this) {
      case OperationalStatus.active:
        return 'ACTIVE';
      case OperationalStatus.suspended:
        return 'SUSPENDED';
      case OperationalStatus.trial:
        return 'TRIAL';
    }
  }

  static OperationalStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return OperationalStatus.active;
      case 'SUSPENDED':
        return OperationalStatus.suspended;
      case 'TRIAL':
        return OperationalStatus.trial;
      default:
        throw ArgumentError('Unknown status: $status');
    }
  }
}
