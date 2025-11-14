import 'package:waste_track_driver_app/entities/waypoint/api/mappers/waypoint_mapper.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/repositories/waypoint_repository.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/services/waypoint_service.dart';
import 'package:waste_track_driver_app/entities/waypoint/model/entities/waypoint.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class WayPointRepositoryImpl implements WayPointRepository {
  WayPointRepositoryImpl(this._service);
  final WayPointService _service;

  @override
  Future<Resource<WayPoint>> getById(String id) async {
    final result = await _service.getById(id);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<WayPoint>>> getAll({String? routeId}) async {
    final result = await _service.getAll(routeId: routeId);

    return switch (result) {
      Success(data: final dtoList) => Success(
        dtoList.map((dto) => dto.toDomain()).toList(),
      ),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<WayPoint>>> getByRouteId(String routeId) async {
    final result = await _service.getByRouteId(routeId);

    return switch (result) {
      Success(data: final dtoList) => Success(
        dtoList.map((dto) => dto.toDomain()).toList(),
      ),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<WayPoint>> create(WayPoint waypoint, String routeId) async {
    final request = waypoint.toCreateRequest();
    final result = await _service.create(request, routeId);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<WayPoint>> update(WayPoint waypoint) async {
    final request = waypoint.toUpdateRequest();
    final result = await _service.update(waypoint.id, request);

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
