import 'package:waste_track_driver_app/entities/route/api/mappers/route_mapper.dart';
import 'package:waste_track_driver_app/entities/route/api/repositories/route_repository.dart';
import 'package:waste_track_driver_app/entities/route/api/services/route_service.dart';
import 'package:waste_track_driver_app/entities/route/model/entities/route.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl(this._service);
  final RouteService _service;

  @override
  Future<Resource<Route>> getById(String id) async {
    final result = await _service.getById(id);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<Route>>> getAll({
    String? districtId,
    String? driverId,
    String? vehicleId,
    String? status,
    List<String>? statuses,
  }) async {
    final result = await _service.getAll(
      districtId: districtId,
      driverId: driverId,
      vehicleId: vehicleId,
      status: status,
      statuses: statuses,
    );

    return switch (result) {
      Success(data: final dtoList) =>
          Success(dtoList.map((dto) => dto.toDomain()).toList()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<Route>>> getActiveByDistrictId(String districtId) async {
    final result = await _service.getActiveByDistrictId(districtId);

    return switch (result) {
      Success(data: final dtoList) => Success(
        dtoList.map((dto) => dto.toDomain()).toList(),
      ),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<Route>> create(Route route) async {
    final request = route.toCreateRequest();
    final result = await _service.create(request);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<Route>> update(Route route) async {
    final request = route.toUpdateRequest();
    final result = await _service.update(route.id, request);

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

  @override
  Future<Resource<Route>> generateOptimizedWaypoints(String id) async {
    final result = await _service.generateOptimizedWaypoints(id);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }
}
