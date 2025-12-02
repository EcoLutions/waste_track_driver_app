import 'package:waste_track_driver_app/entities/user_profile/api/dto/create_user_profile_request.dart';
import 'package:waste_track_driver_app/entities/user_profile/api/dto/update_user_profile_request.dart';
import 'package:waste_track_driver_app/entities/user_profile/api/dto/user_profile_response.dart';
import 'package:waste_track_driver_app/entities/user_profile/api/mappers/user_profile_enum_mapper.dart';
import 'package:waste_track_driver_app/entities/user_profile/model/entities/user_profile.dart';
import 'package:waste_track_driver_app/entities/user_profile/model/enums/language.dart';

extension UserProfileResponseMapper on UserProfileResponse {
  UserProfile toDomain() {
    return UserProfile(
      id: id ?? '',
      userId: userId ?? '',
      photoPath: photoPath ?? '',
      districtId: districtId,
      email: email ?? '',
      phoneNumber: phoneNumber,
      emailNotificationsEnabled: emailNotificationsEnabled ?? true,
      smsNotificationsEnabled: smsNotificationsEnabled ?? false,
      pushNotificationsEnabled: pushNotificationsEnabled ?? true,
      language: LanguageMapper.parse(language),
      timezone: timezone ?? 'America/Lima',
      temporalPhotoUrl: temporalPhotoUrl,
      createdAt: _parseDate(createdAt),
      updatedAt: _parseDate(updatedAt),
    );
  }
  DateTime _parseDate(String? date) {
    if (date == null || date.isEmpty) {
      return DateTime(0);
    }

    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime(0);
    }
  }
}

extension UserProfileToCreateRequestMapper on UserProfile {
  CreateUserProfileRequest toCreateRequest() {
    return CreateUserProfileRequest(
      userId: userId,
      photoPath: photoPath,
      districtId: districtId,
      email: email,
      phoneNumber: phoneNumber,
      language: language.toJson(),
      timezone: timezone,
    );
  }
}

extension UserProfileToUpdateRequestMapper on UserProfile {
  UpdateUserProfileRequest toUpdateRequest() {
    return UpdateUserProfileRequest(
      photoPath: photoPath,
      districtId: districtId,
      email: email,
      phoneNumber: phoneNumber,
      emailNotificationsEnabled: emailNotificationsEnabled,
      smsNotificationsEnabled: smsNotificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled,
      language: language.toJson(),
      timezone: timezone,
    );
  }
}
