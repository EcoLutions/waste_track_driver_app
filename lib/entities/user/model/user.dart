import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/user/model/user_role.dart';
import 'package:waste_track_driver_app/entities/user/model/user_status.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
sealed class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    required UserStatus status,
    required List<UserRole> roles,
    @Default(0) int failedLoginAttempts,
    String? lastLoginAt,
    String? passwordChangedAt,
    String? createdAt,
    String? updatedAt,
  }) = _User;

  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // ==================== BUSINESS LOGIC ====================

  bool hasRole(UserRole role) => roles.contains(role);

  bool hasAnyRole(List<UserRole> rolesToCheck) {
    return rolesToCheck.any((role) => roles.contains(role));
  }

  bool get isAdmin => hasAnyRole([UserRole.superAdmin, UserRole.municipalAdmin]);

  bool get canAccessDriverApp => hasAnyRole([UserRole.driver, UserRole.superAdmin]);

  bool get isActive => status == UserStatus.active;

  bool get isBlocked => status.isBlocked;

  bool get canLogin => status.canLogin;

  UserRole get primaryRole => roles.isNotEmpty ? roles.first : UserRole.citizen;

  String get rolesDisplayName => roles.map((role) => role.displayName).join(', ');

  bool get requiresPasswordChange => passwordChangedAt == null;

  bool get isCloseToLockout => failedLoginAttempts >= 3;
}