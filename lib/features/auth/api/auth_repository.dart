import 'package:waste_track_driver_app/entities/user/user.dart';
import 'package:waste_track_driver_app/features/auth/model/sign_in_request.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class AuthRepository {
  Future<Resource<User>> signIn(SignInRequest request);
  Future<Resource<User>> validateToken();
  Future<bool> hasToken();
  Future<void> logout();
}