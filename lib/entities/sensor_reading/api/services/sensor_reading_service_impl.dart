import 'package:waste_track_driver_app/entities/sensor_reading/api/dto/create_sensor_reading_request.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/api/dto/sensor_reading_response.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/api/dto/update_sensor_reading_request.dart';
import 'package:waste_track_driver_app/entities/sensor_reading/api/services/sensor_reading_service.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class SensorReadingServiceImpl implements SensorReadingService {
  SensorReadingServiceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<Resource<SensorReadingResponse>> getById(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/sensor-readings/$id'),
          (data) => SensorReadingResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<List<SensorReadingResponse>>> getAll() async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/sensor-readings'),
          (data) => (data as List)
          .map((e) => SensorReadingResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<SensorReadingResponse>> create(
      CreateSensorReadingRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.post(
        '${ApiConstants.baseUrl}/sensor-readings',
        data: request.toJson(),
      ),
          (data) => SensorReadingResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<SensorReadingResponse>> update(
      String id, UpdateSensorReadingRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.put(
        '${ApiConstants.baseUrl}/sensor-readings/$id',
        data: request.toJson(),
      ),
          (data) => SensorReadingResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<void>> delete(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.delete('${ApiConstants.baseUrl}/sensor-readings/$id'),
          (_) {},
    );
  }
}
