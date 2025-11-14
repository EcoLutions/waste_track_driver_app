import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_waypoint_request.freezed.dart';
part 'update_waypoint_request.g.dart';

@freezed
sealed class UpdateWayPointRequest with _$UpdateWayPointRequest {
  const factory UpdateWayPointRequest({
    int? sequenceOrder,
    String? priority,
    String? estimatedArrivalTime,
  }) = _UpdateWayPointRequest;

  factory UpdateWayPointRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateWayPointRequestFromJson(json);
}
