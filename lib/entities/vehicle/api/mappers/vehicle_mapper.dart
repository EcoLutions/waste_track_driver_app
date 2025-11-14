import 'package:waste_track_driver_app/entities/vehicle/api/dto/create_vehicle_request.dart';
import 'package:waste_track_driver_app/entities/vehicle/api/dto/update_vehicle_request.dart';
import 'package:waste_track_driver_app/entities/vehicle/api/dto/vehicle_response.dart';
import 'package:waste_track_driver_app/entities/vehicle/api/mappers/vehicle_enum_mapper.dart';
import 'package:waste_track_driver_app/entities/vehicle/model/entities/vehicle.dart';

extension VehicleResponseMapper on VehicleResponse {
  Vehicle toDomain() {
    return Vehicle(
      id: id ?? '',
      licensePlate: licensePlate ?? '',
      vehicleType: VehicleTypeMapper.parse(vehicleType),
      volumeCapacity: _parseDouble(volumeCapacity),
      weightCapacity: weightCapacity ?? 0,
      mileage: mileage ?? 0,
      districtId: districtId ?? '',
      lastMaintenanceDate: _parseDateOrNull(lastMaintenanceDate),
      nextMaintenanceDate: _parseDateOrNull(nextMaintenanceDate),
      isActive: isActive ?? true,
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
}

extension VehicleToCreateRequestMapper on Vehicle {
  CreateVehicleRequest toCreateRequest() {
    return CreateVehicleRequest(
      licensePlate: licensePlate,
      vehicleType: VehicleTypeMapper.toDto(vehicleType),
      volumeCapacity: volumeCapacity.toString(),
      weightCapacity: weightCapacity.toString(),
      districtId: districtId,
    );
  }
}

extension VehicleToUpdateRequestMapper on Vehicle {
  UpdateVehicleRequest toUpdateRequest() {
    return UpdateVehicleRequest(
      vehicleId: id,
      licensePlate: licensePlate,
      vehicleType: VehicleTypeMapper.toDto(vehicleType),
      volumeCapacity: volumeCapacity,
      weightCapacity: weightCapacity.toDouble(),
      lastMaintenanceDate: lastMaintenanceDate?.toIso8601String(),
      nextMaintenanceDate: nextMaintenanceDate?.toIso8601String(),
      isActive: isActive,
    );
  }
}
