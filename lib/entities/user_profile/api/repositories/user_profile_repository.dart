
import 'package:waste_track_driver_app/entities/user_profile/model/entities/user_profile.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class UserProfileRepository {
  Future<Resource<UserProfile>> getById(String id);
  Future<Resource<List<UserProfile>>> getAll();
  Future<Resource<UserProfile>> getByUserId(String userId);
  Future<Resource<UserProfile>> create(UserProfile userProfile);
  Future<Resource<UserProfile>> update(String id, UserProfile userProfile);
  Future<Resource<void>> delete(String id);
}
