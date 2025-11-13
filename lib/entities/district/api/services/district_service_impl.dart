import 'package:waste_track_driver_app/entities/district/api/dto/create_district_request.dart';
import 'package:waste_track_driver_app/entities/district/api/dto/district_response.dart';
import 'package:waste_track_driver_app/entities/district/api/dto/update_district_request.dart';
import 'package:waste_track_driver_app/entities/district/api/services/district_service.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class DistrictServiceImpl implements DistrictService {

  DistrictServiceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<Resource<DistrictResponse>> getById(String id) async {
    return _dioClient.handleRequest(
      () => _dioClient.dio.get('${ApiConstants.baseUrl}/districts/$id'),
      (data) => DistrictResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<List<DistrictResponse>>> getAll() async {
    return _dioClient.handleRequest(
      () => _dioClient.dio.get('${ApiConstants.baseUrl}/districts'),
      (data) => (data as List)
          .map((e) => DistrictResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<DistrictResponse>> create(
      CreateDistrictRequest request) async {
    return _dioClient.handleRequest(
      () => _dioClient.dio.post(
        '${ApiConstants.baseUrl}/districts',
        data: request.toJson(),
      ),
      (data) => DistrictResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<DistrictResponse>> update(
      UpdateDistrictRequest request) async {
    return _dioClient.handleRequest(
      () => _dioClient.dio.put(
        '${ApiConstants.baseUrl}/districts',
        data: request.toJson(),
      ),
      (data) => DistrictResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<void>> delete(String id) async {
    return _dioClient.handleRequest(
      () => _dioClient.dio.delete('${ApiConstants.baseUrl}/districts/$id'),
      (_) {},
    );
  }
}
