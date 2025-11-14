import 'package:waste_track_driver_app/entities/container/api/mappers/container_mapper.dart';
import 'package:waste_track_driver_app/entities/container/api/repositories/container_repository.dart';
import 'package:waste_track_driver_app/entities/container/api/services/container_service.dart';
import 'package:waste_track_driver_app/entities/container/model/entities/container.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class ContainerRepositoryImpl implements ContainerRepository {
  ContainerRepositoryImpl(this._service);
  final ContainerService _service;

  @override
  Future<Resource<Container>> getById(String id) async {
    final result = await _service.getById(id);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<Container>>> getAll() async {
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
  Future<Resource<List<Container>>> getAllByDistrictId(
      String districtId) async {
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
  Future<Resource<List<Container>>> getContainersInAlert(
      String districtId) async {
    final result = await _service.getContainersInAlert(districtId);

    return switch (result) {
      Success(data: final dtoList) => Success(
        dtoList.map((dto) => dto.toDomain()).toList(),
      ),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<Container>> create(Container container) async {
    final request = container.toCreateRequest();
    final result = await _service.create(request);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<Container>> update(Container container) async {
    final request = container.toUpdateRequest();
    final result = await _service.update(container.id, request);

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
