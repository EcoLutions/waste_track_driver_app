import 'dart:io';

import 'package:dio/dio.dart';
import 'package:waste_track_driver_app/entities/user_profile/api/dto/create_user_profile_request.dart';
import 'package:waste_track_driver_app/entities/user_profile/api/dto/update_user_profile_request.dart';
import 'package:waste_track_driver_app/entities/user_profile/api/dto/user_profile_response.dart';
import 'package:waste_track_driver_app/entities/user_profile/api/services/user_profile_service.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class UserProfileServiceImpl implements UserProfileService {

  UserProfileServiceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<Resource<UserProfileResponse>> getById(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/user-profiles/$id'),
          (data) => UserProfileResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<List<UserProfileResponse>>> getAll() async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.get('${ApiConstants.baseUrl}/user-profiles'),
          (data) => (data as List)
          .map((e) => UserProfileResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Resource<UserProfileResponse>> getByUserId(String userId) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio
          .get('${ApiConstants.baseUrl}/user-profiles/user/$userId'),
          (data) => UserProfileResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<UserProfileResponse>> create(CreateUserProfileRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.post(
        '${ApiConstants.baseUrl}/user-profiles',
        data: request.toJson(),
      ),
          (data) => UserProfileResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<UserProfileResponse>> update(String id, UpdateUserProfileRequest request) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.put(
        '${ApiConstants.baseUrl}/user-profiles/$id',
        data: request.toJson(),
      ),
          (data) => UserProfileResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Resource<void>> delete(String id) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.delete('${ApiConstants.baseUrl}/user-profiles/$id'),
          (_) {},
    );
  }
  @override
  Future<Resource<String>> uploadPhoto(File file) async {
    return _dioClient.handleRequest(
          () async {
        String fileName = file.path.split('/').last;
        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path, filename: fileName),
        });

        return _dioClient.dio.post(
          '${ApiConstants.baseUrl}/photos/upload',
          data: formData,
        );
      },
          (data) => data['filePath'] as String, // El backend devuelve PhotoResource { filePath: "..." }
    );
  }
}
