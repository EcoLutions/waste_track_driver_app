import 'package:freezed_annotation/freezed_annotation.dart';

enum UserRole {
  @JsonValue('SUPER_ADMIN')
  superAdmin,
  @JsonValue('MUNICIPAL_ADMIN')
  municipalAdmin,
  @JsonValue('DRIVER')
  driver,
  @JsonValue('CITIZEN')
  citizen;

  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.municipalAdmin:
        return 'Admin Municipal';
      case UserRole.driver:
        return 'Conductor';
      case UserRole.citizen:
        return 'Ciudadano';
    }
  }

  bool get isAdmin {
    return this == UserRole.superAdmin || this == UserRole.municipalAdmin;
  }

  bool get canAccessDriverApp {
    return this == UserRole.driver || this == UserRole.superAdmin;
  }
}

extension UserRoleExtension on UserRole {
  String toJson() {
    switch (this) {
      case UserRole.superAdmin:
        return 'SUPER_ADMIN';
      case UserRole.municipalAdmin:
        return 'MUNICIPAL_ADMIN';
      case UserRole.driver:
        return 'DRIVER';
      case UserRole.citizen:
        return 'CITIZEN';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'SUPER_ADMIN':
        return UserRole.superAdmin;
      case 'MUNICIPAL_ADMIN':
        return UserRole.municipalAdmin;
      case 'DRIVER':
        return UserRole.driver;
      case 'CITIZEN':
        return UserRole.citizen;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }
}