import 'package:waste_track_driver_app/entities/sensor_reading/model/entities/sensor_reading.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class SensorReadingRepository {
  Future<Resource<SensorReading>> getById(String id);
  Future<Resource<List<SensorReading>>> getAll();
  Future<Resource<SensorReading>> create(SensorReading sensorReading);
  Future<Resource<SensorReading>> update(SensorReading sensorReading);
  Future<Resource<void>> delete(String id);
}
