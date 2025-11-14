import 'package:waste_track_driver_app/entities/route/api/dto/create_route_request.dart';
import 'package:waste_track_driver_app/entities/route/api/dto/route_response.dart';
import 'package:waste_track_driver_app/entities/route/api/dto/update_route_request.dart';
import 'package:waste_track_driver_app/entities/route/api/services/route_service.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class RouteServiceImpl implements RouteService {
  RouteServiceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<Resource<RouteResponse>> getById(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/routes/$id'),
          (data) => RouteResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<List<RouteResponse>>> getAll() async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/routes'),
          (data) => (data as List)
          .map((e) => RouteResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<List<RouteResponse>>> getActiveByDistrictId(
      String districtId) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio
          .get('${ApiConstants.baseUrl}/routes/district/$districtId/active'),
          (data) => (data as List)
          .map((e) => RouteResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<RouteResponse>> create(CreateRouteRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.post(
        '${ApiConstants.baseUrl}/routes',
        data: request.toJson(),
      ),
          (data) => RouteResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<RouteResponse>> update(
      String id, UpdateRouteRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.put(
        '${ApiConstants.baseUrl}/routes/$id',
        data: request.toJson(),
      ),
          (data) => RouteResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<void>> delete(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.delete('${ApiConstants.baseUrl}/routes/$id'),
          (_) {},
    );
  }

  @override
  Future<Resource<RouteResponse>> generateOptimizedWaypoints(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.post(
        '${ApiConstants.baseUrl}/routes/$id/generate-optimized-waypoints',
      ),
          (data) => RouteResponse.fromJson(data as Map<String, dynamic>),
    );
  }
}
