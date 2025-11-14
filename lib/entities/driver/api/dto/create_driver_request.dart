import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_driver_request.freezed.dart';
part 'create_driver_request.g.dart';

@freezed
sealed class CreateDriverRequest with _$CreateDriverRequest {
  const factory CreateDriverRequest({
    String? districtId,
    String? firstName,
    String? lastName,
    String? documentNumber,
    String? phoneNumber,
    String? userId,
    String? driverLicense,
    String? licenseExpiryDate,
    String? emailAddress,
  }) = _CreateDriverRequest;

  factory CreateDriverRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDriverRequestFromJson(json);
}
