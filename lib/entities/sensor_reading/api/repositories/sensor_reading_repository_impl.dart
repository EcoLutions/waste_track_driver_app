import 'package:waste_track_driver_app/entities/sensor_reading/api/mappers/sensor_reading_mapper.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/api/repositories/sensor_reading_repository.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/api/services/sensor_reading_service.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/model/entities/sensor_reading.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class SensorReadingRepositoryImpl implements SensorReadingRepository {
  SensorReadingRepositoryImpl(this._service);
  final SensorReadingService _service;

  @override
  Future<Resource<SensorReading>> getById(String id) async {
    final result = await _service.getById(id);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<SensorReading>>> getAll() async {
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
  Future<Resource<SensorReading>> create(SensorReading sensorReading) async {
    final request = sensorReading.toCreateRequest();
    final result = await _service.create(request);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<SensorReading>> update(SensorReading sensorReading) async {
    final request = sensorReading.toUpdateRequest();
    final result = await _service.update(sensorReading.id, request);

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
