import 'package:waste_track_driver_app/entities/district/api/mappers/district_mapper.dart';
import 'package:waste_track_driver_app/entities/district/api/repositories/district_repository.dart';
import 'package:waste_track_driver_app/entities/district/api/services/district_service.dart';
import 'package:waste_track_driver_app/entities/district/model/entities/district.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class DistrictRepositoryImpl implements DistrictRepository {

  DistrictRepositoryImpl(this._service);
  final DistrictService _service;

  @override
  Future<Resource<District>> getById(String id) async {
    final result = await _service.getById(id);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<District>>> getAll() async {
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
  Future<Resource<District>> create({
    required District district,
    required String primaryAdminEmail,
    required String primaryAdminUsername,
    required String planId,
  }) async {
    final request = district.toCreateRequest(
      primaryAdminEmail: primaryAdminEmail,
      primaryAdminUsername: primaryAdminUsername,
      planId: planId,
    );
    final result = await _service.create(request);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<District>> update(District district) async {
    final request = district.toUpdateRequest();
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
