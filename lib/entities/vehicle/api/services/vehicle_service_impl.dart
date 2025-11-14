import 'package:waste_track_driver_app/entities/vehicle/api/dto/create_vehicle_request.dart';
import 'package:waste_track_driver_app/entities/vehicle/api/dto/update_vehicle_request.dart';
import 'package:waste_track_driver_app/entities/vehicle/api/dto/vehicle_response.dart';
import 'package:waste_track_driver_app/entities/vehicle/api/services/vehicle_service.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class VehicleServiceImpl implements VehicleService {
  VehicleServiceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<Resource<VehicleResponse>> getById(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/vehicles/$id'),
          (data) => VehicleResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<List<VehicleResponse>>> getAll() async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/vehicles'),
          (data) => (data as List)
          .map((e) => VehicleResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<List<VehicleResponse>>> getAllByDistrictId(
      String districtId) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio
          .get('${ApiConstants.baseUrl}/vehicles/district/$districtId'),
          (data) => (data as List)
          .map((e) => VehicleResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<VehicleResponse>> create(CreateVehicleRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.post(
        '${ApiConstants.baseUrl}/vehicles',
        data: request.toJson(),
      ),
          (data) => VehicleResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<VehicleResponse>> update(UpdateVehicleRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.put(
        '${ApiConstants.baseUrl}/vehicles',
        data: request.toJson(),
      ),
          (data) => VehicleResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<void>> delete(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.delete('${ApiConstants.baseUrl}/vehicles/$id'),
          (_) {},
    );
  }
}
