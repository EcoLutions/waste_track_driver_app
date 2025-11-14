import 'package:freezed_annotation/freezed_annotation.dart';

part 'district_response.freezed.dart';
part 'district_response.g.dart';

@freezed
sealed class DistrictResponse with _$DistrictResponse {
  const factory DistrictResponse({
    String? id,
    String? name,
    String? code,
    String? depotLatitud,
    String? depotLongitude,
    String? operationalStatus,
    String? serviceStartDate,
    String? operationStartTime,
    String? operationEndTime,
    String? maxRouteDuration,
    String? planId,
    String? planName,
    int? maxVehicles,
    int? maxDrivers,
    int? maxContainers,
    String? currency,
    String? price,
    String? billingPeriod,
    int? currentVehicleCount,
    int? currentDriverCount,
    int? currentContainerCount,
    String? createdAt,
    String? updatedAt,
  }) = _DistrictResponse;

  factory DistrictResponse.fromJson(Map<String, dynamic> json) =>
      _$DistrictResponseFromJson(json);
}
