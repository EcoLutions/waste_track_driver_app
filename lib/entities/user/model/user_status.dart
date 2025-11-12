import 'package:freezed_annotation/freezed_annotation.dart';

enum UserStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('PENDING_ACTIVATION')
  pendingActivation;

  String get displayName {
    switch (this) {
      case UserStatus.active:
        return 'Activo';
      case UserStatus.inactive:
        return 'Inactivo';
      case UserStatus.suspended:
        return 'Suspendido';
      case UserStatus.pendingActivation:
        return 'Pendiente de Activación';
    }
  }

  bool get canLogin {
    return this == UserStatus.active;
  }

  bool get isBlocked {
    return this == UserStatus.suspended || this == UserStatus.inactive;
  }
}

extension UserStatusExtension on UserStatus {
  String toJson() {
    switch (this) {
      case UserStatus.active:
        return 'ACTIVE';
      case UserStatus.inactive:
        return 'INACTIVE';
      case UserStatus.suspended:
        return 'SUSPENDED';
      case UserStatus.pendingActivation:
        return 'PENDING_ACTIVATION';
    }
  }

  static UserStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return UserStatus.active;
      case 'INACTIVE':
        return UserStatus.inactive;
      case 'SUSPENDED':
        return UserStatus.suspended;
      case 'PENDING_ACTIVATION':
        return UserStatus.pendingActivation;
      default:
        throw ArgumentError('Unknown status: $status');
    }
  }
}