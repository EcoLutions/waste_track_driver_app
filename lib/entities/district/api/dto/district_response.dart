import 'package:freezed_annotation/freezed_annotation.dart';

part 'district_response.freezed.dart';
part 'district_response.g.dart';

@freezed
sealed class DistrictResponse with _$DistrictResponse {
  const factory DistrictResponse({
    String? id,
    String? name,
    String? code,
    String? boundaries,
    String? operationalStatus,
    String? serviceStartDate,
    String? subscriptionId,
    int? maxVehicles,
    int? maxDrivers,
    int? maxContainers,
    String? primaryAdminEmail,
    String? createdAt,
    String? updatedAt,
  }) = _DistrictResponse;

  factory DistrictResponse.fromJson(Map<String, dynamic> json) =>
      _$DistrictResponseFromJson(json);
}
