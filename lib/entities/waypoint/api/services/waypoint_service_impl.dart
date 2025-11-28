import 'package:waste_track_driver_app/entities/waypoint/api/dto/create_waypoint_request.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/dto/update_waypoint_request.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/dto/waypoint_response.dart';
import 'package:waste_track_driver_app/entities/waypoint/api/services/waypoint_service.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class WayPointServiceImpl implements WayPointService {
  WayPointServiceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<Resource<WayPointResponse>> getById(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/waypoints/$id'),
          (data) => WayPointResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<List<WayPointResponse>>> getAll({String? routeId}) async {
    final path = routeId != null
        ? '${ApiConstants.baseUrl}/waypoints?routeId=$routeId'
        : '${ApiConstants.baseUrl}/waypoints';

    return _dioClient.handleRequest(
          () => _dioClient.dio.get(path),
          (data) => (data as List)
          .map((e) => WayPointResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<List<WayPointResponse>>> getByRouteId(String routeId) async {
    return getAll(routeId: routeId);
  }

  @override
  Future<Resource<WayPointResponse>> create(
      CreateWayPointRequest request, String routeId) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.post(
        '${ApiConstants.baseUrl}/waypoints',
        data: request.toJson(),
        queryParameters: {'routeId': routeId},
      ),
          (data) => WayPointResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<WayPointResponse>> update(
      String id, UpdateWayPointRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.put(
        '${ApiConstants.baseUrl}/waypoints/$id',
        data: request.toJson(),
      ),
          (data) => WayPointResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<void>> delete(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.delete('${ApiConstants.baseUrl}/waypoints/$id'),
          (_) {},
    );
  }

  @override
  Future<Resource<WayPointResponse>> markAsVisited(String id, String routeId) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.patch(
        '${ApiConstants.baseUrl}/waypoints/$id/mark-visited',
        data: {
          'routeId': routeId,
          'arrivalTime': DateTime.now().toIso8601String(),
        },
      ),
          (data) => WayPointResponse.fromJson(data as Map<String, dynamic>),
    );
  }
}
