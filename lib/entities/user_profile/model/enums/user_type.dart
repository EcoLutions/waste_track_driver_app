import 'package:freezed_annotation/freezed_annotation.dart';

enum UserType {
  @JsonValue('CITIZEN')
  citizen,

  @JsonValue('DRIVER')
  driver,

  @JsonValue('ADMINISTRATOR')
  administrator,

  @JsonValue('SUPER_ADMINISTRATOR')
  superAdministrator;

  String get displayName {
    switch (this) {
      case UserType.citizen:
        return 'Ciudadano';
      case UserType.driver:
        return 'Conductor';
      case UserType.administrator:
        return 'Administrador';
      case UserType.superAdministrator:
        return 'Super Administrador';
    }
  }
}

extension UserTypeExtension on UserType {
  String toJson() {
    switch (this) {
      case UserType.citizen:
        return 'CITIZEN';
      case UserType.driver:
        return 'DRIVER';
      case UserType.administrator:
        return 'ADMINISTRATOR';
      case UserType.superAdministrator:
        return 'SUPER_ADMINISTRATOR';
    }
  }

  static UserType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'CITIZEN':
        return UserType.citizen;
      case 'DRIVER':
        return UserType.driver;
      case 'ADMINISTRATOR':
        return UserType.administrator;
      case 'SUPER_ADMINISTRATOR':
        return UserType.superAdministrator;
      default:
        throw ArgumentError('Unknown user type: $type');
    }
  }
}
