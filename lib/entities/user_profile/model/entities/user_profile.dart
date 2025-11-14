import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/user_profile/model/enums/language.dart';

part 'user_profile.freezed.dart';

@freezed
sealed class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String userId,
    required String photoPath,
    required String email,
    required bool emailNotificationsEnabled,
    required bool smsNotificationsEnabled,
    required bool pushNotificationsEnabled,
    required Language language,
    required String timezone,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? districtId,
    String? phoneNumber,
    String? temporalPhotoUrl,
  }) = _UserProfile;

  const UserProfile._();

  String get languageDisplayName => language.displayName;

  bool get hasNotificationsEnabled =>
      emailNotificationsEnabled || smsNotificationsEnabled || pushNotificationsEnabled;

  bool get hasPhoneNumber => phoneNumber != null && phoneNumber!.isNotEmpty;

  bool get hasDistrictId => districtId != null && districtId!.isNotEmpty;

  bool get hasTemporalPhotoUrl =>
      temporalPhotoUrl != null && temporalPhotoUrl!.isNotEmpty;
}
