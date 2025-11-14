import 'package:waste_track_driver_app/entities/waypoint/api/dto/create_waypoint_request.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/dto/update_waypoint_request.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/dto/waypoint_response.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/mappers/waypoint_enum_mapper.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/entities/waypoint.dart';

extension WayPointResponseMapper on WayPointResponse {
  WayPoint toDomain() {
    return WayPoint(
      id: id ?? '',
      containerId: containerId ?? '',
      sequenceOrder: sequenceOrder ?? 0,
      priority: PriorityLevelMapper.parse(priority),
      status: WayPointStatusMapper.parse(status),
      estimatedArrivalTime: _parseDateOrNull(estimatedArrivalTime),
      actualArrivalTime: _parseDateOrNull(actualArrivalTime),
      createdAt: _parseDate(createdAt),
      updatedAt: _parseDateOrNull(updatedAt),
    );
  }

  DateTime _parseDate(String? date) {
    if (date == null || date.isEmpty) {
      return DateTime(0);
    }

    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime(0);
    }
  }

  DateTime? _parseDateOrNull(String? date) {
    if (date == null || date.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
}

extension WayPointToCreateRequestMapper on WayPoint {
  CreateWayPointRequest toCreateRequest() {
    return CreateWayPointRequest(
      containerId: containerId,
      sequenceOrder: sequenceOrder,
      priority: PriorityLevelMapper.toDto(priority),
    );
  }
}

extension WayPointToUpdateRequestMapper on WayPoint {
  UpdateWayPointRequest toUpdateRequest() {
    return UpdateWayPointRequest(
      sequenceOrder: sequenceOrder,
      priority: PriorityLevelMapper.toDto(priority),
      estimatedArrivalTime: estimatedArrivalTime?.toIso8601String(),
    );
  }
}
