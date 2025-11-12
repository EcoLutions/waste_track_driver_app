import 'package:waste_track_driver_app/entities/user/api/dto/user_response.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class UserService {
  Future<Resource<UserResponse>> getCurrentUser();
  Future<Resource<UserResponse>> getUserById(String userId);
  Future<Resource<List<UserResponse>>> getAllUsers();
}