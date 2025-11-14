import 'package:waste_track_driver_app/entities/district/api/dto/create_district_request.dart';
import 'package:waste_track_driver_app/entities/district/api/dto/district_response.dart';
import 'package:waste_track_driver_app/entities/district/api/dto/update_district_request.dart';
import 'package:waste_track_driver_app/entities/district/api/mappers/district_enum_mapper.dart';
import 'package:waste_track_driver_app/entities/district/model/entities/district.dart';

extension DistrictResponseMapper on DistrictResponse {
  District toDomain() {
    return District(
      id: id ?? '',
      name: name ?? '',
      code: code ?? '',
      depotLatitud: depotLatitud,
      depotLongitude: depotLongitude,
      operationalStatus: OperationalStatusMapper.parse(operationalStatus),
      serviceStartDate: _parseDateOrNull(serviceStartDate),
      operationStartTime: operationStartTime,
      operationEndTime: operationEndTime,
      maxRouteDuration: maxRouteDuration,
      planId: planId,
      planName: planName,
      maxVehicles: maxVehicles ?? 0,
      maxDrivers: maxDrivers ?? 0,
      maxContainers: maxContainers ?? 0,
      currency: currency,
      price: price,
      billingPeriod: billingPeriod,
      currentVehicleCount: currentVehicleCount ?? 0,
      currentDriverCount: currentDriverCount ?? 0,
      currentContainerCount: currentContainerCount ?? 0,
      createdAt: _parseDate(createdAt),
      updatedAt: _parseDate(updatedAt),
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

extension DistrictToCreateRequestMapper on District {
  CreateDistrictRequest toCreateRequest({
    required String primaryAdminEmail,
    required String primaryAdminUsername,
    required String planId,
  }) {
    return CreateDistrictRequest(
      name: name,
      code: code,
      primaryAdminEmail: primaryAdminEmail,
      primaryAdminUsername: primaryAdminUsername,
      planId: planId,
    );
  }
}

extension DistrictToUpdateRequestMapper on District {
  UpdateDistrictRequest toUpdateRequest() {
    return UpdateDistrictRequest(
      districtId: id,
      name: name,
      code: code,
      depotLatitud: depotLatitud,
      depotLongitude: depotLongitude,
      operationStartTime: operationStartTime,
      operationEndTime: operationEndTime,
      maxRouteDuration: maxRouteDuration,
    );
  }
}
