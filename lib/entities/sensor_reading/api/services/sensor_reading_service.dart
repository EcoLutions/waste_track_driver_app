import 'package:waste_track_driver_app/entities/sensor_reading/api/dto/create_sensor_reading_request.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/api/dto/sensor_reading_response.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/api/dto/update_sensor_reading_request.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class SensorReadingService {
  Future<Resource<SensorReadingResponse>> getById(String id);
  Future<Resource<List<SensorReadingResponse>>> getAll();
  Future<Resource<SensorReadingResponse>> create(CreateSensorReadingRequest request);
  Future<Resource<SensorReadingResponse>> update(String id, UpdateSensorReadingRequest request);
  Future<Resource<void>> delete(String id);
}
