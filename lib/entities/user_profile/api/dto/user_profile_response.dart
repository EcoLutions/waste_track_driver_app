import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_response.freezed.dart';
part 'user_profile_response.g.dart';

@freezed
sealed class UserProfileResponse with _$UserProfileResponse {
  const factory UserProfileResponse({
    String? id,
    String? userId,
    String? photoPath,
    String? userType,
    String? districtId,
    String? email,
    String? phoneNumber,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
    bool? pushNotificationsEnabled,
    String? language,
    String? timezone,
    bool? isActive,
    String? temporalPhotoUrl,
    String? createdAt,
    String? updatedAt,
  }) = _UserProfileResponse;

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseFromJson(json);
}
