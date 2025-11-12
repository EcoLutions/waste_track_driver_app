import 'package:freezed_annotation/freezed_annotation.dart';

enum UserRole {
  @JsonValue('ROLE_SUPER_ADMIN')
  superAdmin,
  @JsonValue('ROLE_MUNICIPAL_ADMIN')
  municipalAdmin,
  @JsonValue('ROLE_DRIVER')
  driver,
  @JsonValue('ROLE_CITIZEN')
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
        return 'ROLE_SUPER_ADMIN';
      case UserRole.municipalAdmin:
        return 'ROLE_MUNICIPAL_ADMIN';
      case UserRole.driver:
        return 'ROLE_DRIVER';
      case UserRole.citizen:
        return 'ROLE_CITIZEN';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'ROLE_SUPER_ADMIN':
        return UserRole.superAdmin;
      case 'ROLE_MUNICIPAL_ADMIN':
        return UserRole.municipalAdmin;
      case 'ROLE_DRIVER':
        return UserRole.driver;
      case 'ROLE_CITIZEN':
        return UserRole.citizen;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }
}