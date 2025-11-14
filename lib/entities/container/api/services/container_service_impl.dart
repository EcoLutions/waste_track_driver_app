import 'package:waste_track_driver_app/entities/container/api/dto/container_response.dart';
import 'package:waste_track_driver_app/entities/container/api/dto/create_container_request.dart';
import 'package:waste_track_driver_app/entities/container/api/dto/update_container_request.dart';
import 'package:waste_track_driver_app/entities/container/api/services/container_service.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class ContainerServiceImpl implements ContainerService {
  ContainerServiceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<Resource<ContainerResponse>> getById(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/containers/$id'),
          (data) => ContainerResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<List<ContainerResponse>>> getAll() async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/containers'),
          (data) => (data as List)
          .map((e) => ContainerResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<List<ContainerResponse>>> getAllByDistrictId(
      String districtId) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio
          .get('${ApiConstants.baseUrl}/containers/district/$districtId'),
          (data) => (data as List)
          .map((e) => ContainerResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<List<ContainerResponse>>> getContainersInAlert(
      String districtId) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio
          .get('${ApiConstants.baseUrl}/containers/district/$districtId/alert'),
          (data) => (data as List)
          .map((e) => ContainerResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<ContainerResponse>> create(
      CreateContainerRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.post(
        '${ApiConstants.baseUrl}/containers',
        data: request.toJson(),
      ),
          (data) => ContainerResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<ContainerResponse>> update(
      String id, UpdateContainerRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.put(
        '${ApiConstants.baseUrl}/containers/$id',
        data: request.toJson(),
      ),
          (data) => ContainerResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<void>> delete(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.delete('${ApiConstants.baseUrl}/containers/$id'),
          (_) {},
    );
  }
}
