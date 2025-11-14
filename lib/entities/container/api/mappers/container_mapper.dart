import 'package:waste_track_driver_app/entities/container/api/dto/container_response.dart';
import 'package:waste_track_driver_app/entities/container/api/dto/create_container_request.dart';
import 'package:waste_track_driver_app/entities/container/api/dto/update_container_request.dart';
import 'package:waste_track_driver_app/entities/container/api/mappers/container_enum_mapper.dart';
import 'package:waste_track_driver_app/entities/container/model/entities/container.dart';

extension ContainerResponseMapper on ContainerResponse {
  Container toDomain() {
    return Container(
      id: id ?? '',
      latitude: _parseDouble(latitude),
      longitude: _parseDouble(longitude),
      volumeLiters: volumeLiters ?? 0,
      maxWeightKg: maxWeightKg ?? 0,
      containerType: ContainerTypeMapper.parse(containerType),
      status: ContainerStatusMapper.parse(status),
      currentFillLevel: currentFillLevel ?? 0,
      sensorId: sensorId,
      lastReadingTimestamp: _parseDateOrNull(lastReadingTimestamp),
      districtId: districtId ?? '',
      lastCollectionDate: _parseDateOrNull(lastCollectionDate),
      collectionFrequencyDays: collectionFrequencyDays ?? 7,
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

extension ContainerToCreateRequestMapper on Container {
  CreateContainerRequest toCreateRequest() {
    return CreateContainerRequest(
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      volumeLiters: volumeLiters,
      maxWeightKg: maxWeightKg,
      sensorId: sensorId,
      containerType: ContainerTypeMapper.toDto(containerType),
      districtId: districtId,
      collectionFrequencyDays: collectionFrequencyDays,
    );
  }
}

extension ContainerToUpdateRequestMapper on Container {
  UpdateContainerRequest toUpdateRequest() {
    return UpdateContainerRequest(
      containerId: id,
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      volumeLiters: volumeLiters,
      maxWeightKg: maxWeightKg,
      sensorId: sensorId,
      containerType: ContainerTypeMapper.toDto(containerType),
      collectionFrequencyDays: collectionFrequencyDays,
    );
  }
}
