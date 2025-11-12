import 'package:waste_track_driver_app/entities/user/api/dto/user_response.dart';
import 'package:waste_track_driver_app/entities/user/model/user.dart';
import 'package:waste_track_driver_app/entities/user/model/user_role.dart';
import 'package:waste_track_driver_app/entities/user/model/user_status.dart';

extension UserResponseMapper on UserResponse {
  User toDomain() {
    return User(
      id: id ?? 'unknown',
      email: email ?? 'no-email@unknown.com',
      username: username ?? 'Unknown User',
      status: _parseStatus(status),
      roles: _parseRoles(roles),
      failedLoginAttempts: failedLoginAttempts ?? 0,
      lastLoginAt: lastLoginAt,
      passwordChangedAt: passwordChangedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  UserStatus _parseStatus(String? status) {
    if (status == null) return UserStatus.inactive;

    try {
      return UserStatusExtension.fromString(status);
    } catch (e) {
      return UserStatus.inactive;
    }
  }

  List<UserRole> _parseRoles(List<String>? roles) {
    if (roles == null || roles.isEmpty) {
      return [UserRole.citizen];
    }

    return roles
        .map((roleString) {
      try {
        return UserRoleExtension.fromString(roleString);
      } catch (e) {
        return null;
      }
    })
        .whereType<UserRole>()
        .toList();
  }
}