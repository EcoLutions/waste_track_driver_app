import 'package:waste_track_driver_app/entities/user/model/user.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class UserService {
  Future<Resource<User>> getCurrentUser();
  Future<Resource<User>> getUserById(String userId);
  Future<Resource<List<User>>> getAllUsers();
}