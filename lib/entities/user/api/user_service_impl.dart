import 'package:dio/dio.dart';
import 'package:waste_track_driver_app/entities/user/api/dto/user_response.dart';
import 'package:waste_track_driver_app/entities/user/api/user_service.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class UserServiceImpl implements UserService {

  UserServiceImpl(this._dioClient);
  final DioClient _dioClient;

  Dio get _dio => _dioClient.dio;

  @override
  Future<Resource<UserResponse>> getCurrentUser() async {
    return _dioClient.handleRequest(
          () => _dio.get('${ApiConstants.authEndpoint}/me'),
          (data) => UserResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<UserResponse>> getUserById(String userId) async {
    return _dioClient.handleRequest(
          () => _dio.get('${ApiConstants.usersEndpoint}/$userId'),
          (data) => UserResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<List<UserResponse>>> getAllUsers() async {
    return _dioClient.handleRequest(
          () => _dio.get(ApiConstants.usersEndpoint),
          (data) => (data as List)
          .map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}