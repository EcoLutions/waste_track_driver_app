import 'package:freezed_annotation/freezed_annotation.dart';

part 'waypoint_response.freezed.dart';
part 'waypoint_response.g.dart';

@freezed
sealed class WayPointResponse with _$WayPointResponse {
  const factory WayPointResponse({
    String? id,
    String? containerId,
    int? sequenceOrder,
    String? priority,
    String? status,
    String? estimatedArrivalTime,
    String? actualArrivalTime,
    String? createdAt,
    String? updatedAt,
  }) = _WayPointResponse;

  factory WayPointResponse.fromJson(Map<String, dynamic> json) =>
      _$WayPointResponseFromJson(json);
}
