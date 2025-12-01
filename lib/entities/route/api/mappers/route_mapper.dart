import 'package:waste_track_driver_app/entities/route/api/dto/create_route_request.dart';
import 'package:waste_track_driver_app/entities/route/api/dto/route_response.dart';
import 'package:waste_track_driver_app/entities/route/api/dto/update_route_request.dart';
import 'package:waste_track_driver_app/entities/route/api/mappers/route_enum_mapper.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';

extension RouteResponseMapper on RouteResponse {
  Route toDomain() {
    return Route(
      id: id ?? '',
      districtId: districtId ?? '',
      vehicleId: vehicleId ?? '',
      driverId: driverId ?? '',
      status: RouteStatusMapper.parse(status),
      scheduledStartAt: _parseDate(scheduledStartAt),
      scheduledEndAt: _parseDateOrNull(scheduledEndAt),
      startedAt: _parseDateOrNull(startedAt),
      completedAt: _parseDateOrNull(completedAt),
      totalDistance: _parseDouble(totalDistance),
      estimatedDuration: _parseDuration(estimatedDuration),
      collectionDuration: _parseDuration(collectionDuration),
      returnDuration: _parseDuration(returnDuration),
      actualDuration: _parseDuration(actualDuration),
      currentLatitude: _parseDoubleOrNull(currentLatitude),
      currentLongitude: _parseDoubleOrNull(currentLongitude),
      lastLocationUpdate: _parseDateOrNull(lastLocationUpdate),
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

  double _parseDouble(String? value) {
    if (value == null || value.isEmpty) {
      return 0.0;
    }

    try {
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }

  double? _parseDoubleOrNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }

  Duration _parseDuration(String? value) {
    if (value == null || value.isEmpty) return Duration.zero;

    try {
      if (!value.startsWith('PT') && !value.startsWith('P')) {
        return Duration.zero;
      }

      final hoursMatch = RegExp(r'(\d+)H').firstMatch(value);
      final minutesMatch = RegExp(r'(\d+)M').firstMatch(value);
      final secondsMatch = RegExp(r'(\d+)S').firstMatch(value);

      final hours = hoursMatch != null ? int.parse(hoursMatch.group(1)!) : 0;
      final minutes = minutesMatch != null ? int.parse(minutesMatch.group(1)!) : 0;
      final seconds = secondsMatch != null ? int.parse(secondsMatch.group(1)!) : 0;

      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } catch (e) {
      return Duration.zero;
    }
  }
}

extension RouteToCreateRequestMapper on Route {
  CreateRouteRequest toCreateRequest() {
    return CreateRouteRequest(
      districtId: districtId,
      driverId: driverId,
      vehicleId: vehicleId,
      scheduledDate: scheduledStartAt.toIso8601String(),
    );
  }
}

extension RouteToUpdateRequestMapper on Route {
  UpdateRouteRequest toUpdateRequest() {
    return UpdateRouteRequest(
      routeId: id,
      scheduledStartAt: scheduledStartAt.toIso8601String(),
    );
  }
}
