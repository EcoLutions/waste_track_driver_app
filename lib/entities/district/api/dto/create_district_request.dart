import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_district_request.freezed.dart';
part 'create_district_request.g.dart';

@freezed
sealed class CreateDistrictRequest with _$CreateDistrictRequest {
  const factory CreateDistrictRequest({
    String? name,
    String? code,
    String? boundaries,
    String? primaryAdminEmail,
  }) = _CreateDistrictRequest;

  factory CreateDistrictRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDistrictRequestFromJson(json);
}
