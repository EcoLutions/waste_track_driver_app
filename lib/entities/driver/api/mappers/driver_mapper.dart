import 'package:waste_track_driver_app/entities/driver/api/dto/create_driver_request.dart';
import 'package:waste_track_driver_app/entities/driver/api/dto/driver_response.dart';
import 'package:waste_track_driver_app/entities/driver/api/dto/update_driver_request.dart';
import 'package:waste_track_driver_app/entities/driver/api/mappers/driver_enum_mapper.dart';
import 'package:waste_track_driver_app/entities/driver/model/entities/driver.dart';

extension DriverResponseMapper on DriverResponse {
  Driver toDomain() {
    return Driver(
      id: id ?? '',
      districtId: districtId ?? '',
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      documentNumber: documentNumber ?? '',
      phoneNumber: phoneNumber ?? '',
      userId: userId ?? '',
      driverLicense: driverLicense ?? '',
      licenseExpiryDate: _parseDate(licenseExpiryDate),
      emailAddress: emailAddress ?? '',
      totalHoursWorked: totalHoursWorked ?? 0,
      lastRouteCompletedAt: _parseDateOrNull(lastRouteCompletedAt),
      status: DriverStatusMapper.parse(status),
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

extension DriverToCreateRequestMapper on Driver {
  CreateDriverRequest toCreateRequest() {
    return CreateDriverRequest(
      districtId: districtId,
      firstName: firstName,
      lastName: lastName,
      documentNumber: documentNumber,
      phoneNumber: phoneNumber,
      userId: userId,
      driverLicense: driverLicense,
      licenseExpiryDate: licenseExpiryDate.toIso8601String(),
      emailAddress: emailAddress,
    );
  }
}

extension DriverToUpdateRequestMapper on Driver {
  UpdateDriverRequest toUpdateRequest() {
    return UpdateDriverRequest(
      driverId: id,
      firstName: firstName,
      lastName: lastName,
      documentNumber: documentNumber,
      phoneNumber: phoneNumber,
      driverLicense: driverLicense,
      licenseExpiryDate: licenseExpiryDate.toIso8601String(),
    );
  }
}
