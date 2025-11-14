import 'package:waste_track_driver_app/entities/driver/api/dto/create_driver_request.dart';
import 'package:waste_track_driver_app/entities/driver/api/dto/driver_response.dart';
import 'package:waste_track_driver_app/entities/driver/api/dto/update_driver_request.dart';
import 'package:waste_track_driver_app/entities/driver/api/services/driver_service.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class DriverServiceImpl implements DriverService {

  DriverServiceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<Resource<DriverResponse>> getById(String id) async {
    return _dioClient.handleRequest(
      () => _dioClient.dio.get('${ApiConstants.baseUrl}/drivers/$id'),
      (data) => DriverResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<List<DriverResponse>>> getAll() async {
    return _dioClient.handleRequest(
      () => _dioClient.dio.get('${ApiConstants.baseUrl}/drivers'),
      (data) => (data as List)
          .map((e) => DriverResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<List<DriverResponse>>> getAllByDistrictId(
      String districtId) async {
    return _dioClient.handleRequest(
      () => _dioClient.dio
          .get('${ApiConstants.baseUrl}/drivers/district/$districtId'),
      (data) => (data as List)
          .map((e) => DriverResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<DriverResponse>> create(CreateDriverRequest request) async {
    return _dioClient.handleRequest(
      () => _dioClient.dio.post(
        '${ApiConstants.baseUrl}/drivers',
        data: request.toJson(),
      ),
      (data) => DriverResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<DriverResponse>> update(UpdateDriverRequest request) async {
    return _dioClient.handleRequest(
      () => _dioClient.dio.put(
        '${ApiConstants.baseUrl}/drivers',
        data: request.toJson(),
      ),
      (data) => DriverResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<void>> delete(String id) async {
    return _dioClient.handleRequest(
      () => _dioClient.dio.delete('${ApiConstants.baseUrl}/drivers/$id'),
      (_) {},
    );
  }
}
