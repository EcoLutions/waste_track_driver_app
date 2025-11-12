import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_request.freezed.dart';
part 'sign_in_request.g.dart';

@freezed
sealed class SignInRequest with _$SignInRequest {
  const factory SignInRequest({
    String? email,
    String? password,
  }) = _SignInRequest;

  factory SignInRequest.fromJson(Map<String, dynamic> json) => _$SignInRequestFromJson(json);
}