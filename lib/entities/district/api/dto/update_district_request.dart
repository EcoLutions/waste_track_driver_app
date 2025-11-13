import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_district_request.freezed.dart';
part 'update_district_request.g.dart';

@freezed
sealed class UpdateDistrictRequest with _$UpdateDistrictRequest {
  const factory UpdateDistrictRequest({
    String? districtId,
    String? name,
    String? code,
    String? boundaries,
    String? primaryAdminEmail,
  }) = _UpdateDistrictRequest;

  factory UpdateDistrictRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateDistrictRequestFromJson(json);
}
