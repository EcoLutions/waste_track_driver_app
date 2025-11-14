import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_driver_request.freezed.dart';
part 'update_driver_request.g.dart';

@freezed
sealed class UpdateDriverRequest with _$UpdateDriverRequest {
  const factory UpdateDriverRequest({
    String? driverId,
    String? firstName,
    String? lastName,
    String? documentNumber,
    String? phoneNumber,
    String? driverLicense,
    String? licenseExpiryDate,
  }) = _UpdateDriverRequest;

  factory UpdateDriverRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateDriverRequestFromJson(json);
}
