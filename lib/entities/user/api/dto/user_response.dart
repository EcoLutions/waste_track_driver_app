import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_response.freezed.dart';
part 'user_response.g.dart';

@freezed
sealed class UserResponse with _$UserResponse {
  const factory UserResponse({
    String? id,
    String? email,
    String? username,
    String? status,
    int? failedLoginAttempts,
    String? lastLoginAt,
    String? passwordChangedAt,
    String? createdAt,
    String? updatedAt,
    List<String>? roles,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}