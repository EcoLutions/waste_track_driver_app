import 'package:waste_track_driver_app/entities/vehicle/api/mappers/vehicle_mapper.dart';
import 'package:waste_track_driver_app/entities/vehicle/api/repositories/vehicle_repository.dart';
import 'package:waste_track_driver_app/entities/vehicle/api/services/vehicle_service.dart';
import 'package:waste_track_driver_app/entities/vehicle/model/entities/vehicle.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._service);
  final VehicleService _service;

  @override
  Future<Resource<Vehicle>> getById(String id) async {
    final result = await _service.getById(id);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<Vehicle>>> getAll() async {
    final result = await _service.getAll();

    return switch (result) {
      Success(data: final dtoList) => Success(
        dtoList.map((dto) => dto.toDomain()).toList(),
      ),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<Vehicle>>> getAllByDistrictId(String districtId) async {
    final result = await _service.getAllByDistrictId(districtId);

    return switch (result) {
      Success(data: final dtoList) => Success(
        dtoList.map((dto) => dto.toDomain()).toList(),
      ),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<Vehicle>> create(Vehicle vehicle) async {
    final request = vehicle.toCreateRequest();
    final result = await _service.create(request);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<Vehicle>> update(Vehicle vehicle) async {
    final request = vehicle.toUpdateRequest();
    final result = await _service.update(request);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<void>> delete(String id) async {
    return _service.delete(id);
  }
}
