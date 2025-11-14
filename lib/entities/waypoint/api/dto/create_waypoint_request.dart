import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_waypoint_request.freezed.dart';
part 'create_waypoint_request.g.dart';

@freezed
sealed class CreateWayPointRequest with _$CreateWayPointRequest {
  const factory CreateWayPointRequest({
    String? containerId,
    int? sequenceOrder,
    String? priority,
  }) = _CreateWayPointRequest;

  factory CreateWayPointRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWayPointRequestFromJson(json);
}
