// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  status: $enumDecode(_$UserStatusEnumMap, json['status']),
  roles: (json['roles'] as List<dynamic>)
      .map((e) => $enumDecode(_$UserRoleEnumMap, e))
      .toList(),
  failedLoginAttempts: (json['failedLoginAttempts'] as num?)?.toInt() ?? 0,
  lastLoginAt: json['lastLoginAt'] as String?,
  passwordChangedAt: json['passwordChangedAt'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'status': _$UserStatusEnumMap[instance.status]!,
  'roles': instance.roles.map((e) => _$UserRoleEnumMap[e]!).toList(),
  'failedLoginAttempts': instance.failedLoginAttempts,
  'lastLoginAt': instance.lastLoginAt,
  'passwordChangedAt': instance.passwordChangedAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'ACTIVE',
  UserStatus.inactive: 'INACTIVE',
  UserStatus.suspended: 'SUSPENDED',
  UserStatus.pendingActivation: 'PENDING_ACTIVATION',
};

const _$UserRoleEnumMap = {
  UserRole.superAdmin: 'SUPER_ADMIN',
  UserRole.municipalAdmin: 'MUNICIPAL_ADMIN',
  UserRole.driver: 'DRIVER',
  UserRole.citizen: 'CITIZEN',
};
