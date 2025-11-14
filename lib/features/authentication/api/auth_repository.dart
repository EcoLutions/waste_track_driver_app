import 'package:waste_track_driver_app/features/authentication/model/auth_basic_data.dart';
import 'package:waste_track_driver_app/features/authentication/model/sign_in_request.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class AuthRepository {
  Future<Resource<AuthBasicData>> signIn(SignInRequest request);
  Future<Resource<String>> forgotPassword(String email);
  Future<Resource<AuthBasicData>> validateToken();
  Future<bool> hasToken();
  Future<void> logout();
}