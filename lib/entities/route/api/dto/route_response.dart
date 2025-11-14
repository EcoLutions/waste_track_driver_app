import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_response.freezed.dart';
part 'route_response.g.dart';

@freezed
sealed class RouteResponse with _$RouteResponse {
  const factory RouteResponse({
    String? id,
    String? districtId,
    String? vehicleId,
    String? driverId,
    String? routeType,
    String? status,
    String? scheduledStartAt,
    String? scheduledEndAt,
    String? startedAt,
    String? completedAt,
    String? totalDistance,
    String? estimatedDuration,
    String? collectionDuration,
    String? returnDuration,
    String? actualDuration,
    String? currentLatitude,
    String? currentLongitude,
    String? lastLocationUpdate,
    String? createdAt,
    String? updatedAt,
  }) = _RouteResponse;

  factory RouteResponse.fromJson(Map<String, dynamic> json) =>
      _$RouteResponseFromJson(json);
}
