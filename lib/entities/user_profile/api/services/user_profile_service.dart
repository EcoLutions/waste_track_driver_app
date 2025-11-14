
import 'package:waste_track_driver_app/entities/user_profile/api/dto/create_user_profile_request.dart';
import 'package:waste_track_driver_app/entities/user_profile/api/dto/update_user_profile_request.dart';
import 'package:waste_track_driver_app/entities/user_profile/api/dto/user_profile_response.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class UserProfileService {
  Future<Resource<UserProfileResponse>> getById(String id);
  Future<Resource<List<UserProfileResponse>>> getAll();
  Future<Resource<UserProfileResponse>> getByUserId(String userId);
  Future<Resource<UserProfileResponse>> create(CreateUserProfileRequest request);
  Future<Resource<UserProfileResponse>> update(String id, UpdateUserProfileRequest request);
  Future<Resource<void>> delete(String id);
}
