import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_route_request.freezed.dart';
part 'update_route_request.g.dart';

@freezed
sealed class UpdateRouteRequest with _$UpdateRouteRequest {
  const factory UpdateRouteRequest({
    String? routeId,
    String? scheduledStartAt,
  }) = _UpdateRouteRequest;

  factory UpdateRouteRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRouteRequestFromJson(json);
}
