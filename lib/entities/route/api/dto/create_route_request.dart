import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_route_request.freezed.dart';
part 'create_route_request.g.dart';

@freezed
sealed class CreateRouteRequest with _$CreateRouteRequest {
  const factory CreateRouteRequest({
    String? districtId,
    String? driverId,
    String? vehicleId,
    String? routeType,
    String? scheduledDate,
  }) = _CreateRouteRequest;

  factory CreateRouteRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRouteRequestFromJson(json);
}
