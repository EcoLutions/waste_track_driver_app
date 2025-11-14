import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_user_profile_request.freezed.dart';
part 'create_user_profile_request.g.dart';

@freezed
sealed class CreateUserProfileRequest with _$CreateUserProfileRequest {
  const factory CreateUserProfileRequest({
    String? userId,
    String? photoPath,
    String? districtId,
    String? email,
    String? phoneNumber,
    String? language,
    String? timezone,
  }) = _CreateUserProfileRequest;

  factory CreateUserProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserProfileRequestFromJson(json);
}