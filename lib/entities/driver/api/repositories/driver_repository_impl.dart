import 'package:waste_track_driver_app/entities/driver/api/mappers/driver_mapper.dart';
import 'package:waste_track_driver_app/entities/driver/api/repositories/driver_repository.dart';
import 'package:waste_track_driver_app/entities/driver/api/services/driver_service.dart';
import 'package:waste_track_driver_app/entities/driver/model/entities/driver.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class DriverRepositoryImpl implements DriverRepository {

  DriverRepositoryImpl(this._service);
  final DriverService _service;

  @override
  Future<Resource<Driver>> getById(String id) async {
    final result = await _service.getById(id);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
        Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<Driver>>> getAll() async {
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
  Future<Resource<List<Driver>>> getAllByDistrictId(String districtId) async {
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
  Future<Resource<Driver>> create(Driver driver) async {
    final request = driver.toCreateRequest();
    final result = await _service.create(request);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
        Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<Driver>> update(Driver driver) async {
    final request = driver.toUpdateRequest();
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
