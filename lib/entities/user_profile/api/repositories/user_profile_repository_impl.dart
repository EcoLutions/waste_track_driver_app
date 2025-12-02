import 'dart:io';

import 'package:waste_track_driver_app/entities/user_profile/api/index.dart';
import 'package:waste_track_driver_app/entities/user_profile/model/entities/user_profile.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {

  UserProfileRepositoryImpl(this._service);
  final UserProfileService _service;

  @override
  Future<Resource<UserProfile>> getById(String id) async {
    final result = await _service.getById(id);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<List<UserProfile>>> getAll() async {
    final result = await _service.getAll();

    return switch (result) {
      Success(data: final dtoList) => Success(
        dtoList.map((dto) => dto.toDomain()).toList(),
      ),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<UserProfile>> getByUserId(String userId) async {
    final result = await _service.getByUserId(userId);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<UserProfile>> create(UserProfile userProfile) async {
    final request = userProfile.toCreateRequest();
    final result = await _service.create(request);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<UserProfile>> update(
      String id, UserProfile userProfile) async {
    var request = userProfile.toUpdateRequest();

    if (userProfile.photoPath.isEmpty) {
      request = request.copyWith(photoPath: null);
    }

    final result = await _service.update(id, request);

    return switch (result) {
      Success(data: final dto) => Success(dto.toDomain()),
      Failure(message: final msg, statusCode: final code) =>
          Failure(message: msg, statusCode: code),
    };
  }

  @override
  Future<Resource<void>> delete(String id) async {
    return _service.delete(id);
  }

  @override
  Future<Resource<String>> uploadPhoto(File file) async {
    return _service.uploadPhoto(file);
  }
}
