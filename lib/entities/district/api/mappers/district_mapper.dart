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
      boundaries: boundaries ?? '',
      operationalStatus: OperationalStatusMapper.parse(operationalStatus),
      serviceStartDate: _parseDate(serviceStartDate),
      subscriptionId: subscriptionId ?? '',
      maxVehicles: maxVehicles ?? 0,
      maxDrivers: maxDrivers ?? 0,
      maxContainers: maxContainers ?? 0,
      primaryAdminEmail: primaryAdminEmail ?? '',
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
}

extension DistrictToCreateRequestMapper on District {
  CreateDistrictRequest toCreateRequest() {
    return CreateDistrictRequest(
      name: name,
      code: code,
      boundaries: boundaries,
      primaryAdminEmail: primaryAdminEmail,
    );
  }
}

extension DistrictToUpdateRequestMapper on District {
  UpdateDistrictRequest toUpdateRequest() {
    return UpdateDistrictRequest(
      districtId: id,
      name: name,
      code: code,
      boundaries: boundaries,
      primaryAdminEmail: primaryAdminEmail,
    );
  }
}
