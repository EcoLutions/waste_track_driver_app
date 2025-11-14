import 'package:freezed_annotation/freezed_annotation.dart';

part 'authenticated_user_response.freezed.dart';
part 'authenticated_user_response.g.dart';

@freezed
sealed class AuthenticatedUserResponse with _$AuthenticatedUserResponse {
  const factory AuthenticatedUserResponse({
      String? id,
      String? email,
      String? username,
      String? token,
  }) = _AuthenticatedUserResponse;

  factory AuthenticatedUserResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthenticatedUserResponseFromJson(json);
}