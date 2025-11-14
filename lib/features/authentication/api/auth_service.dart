import 'package:waste_track_driver_app/features/authentication/model/authenticated_user_response.dart';
import 'package:waste_track_driver_app/features/authentication/model/sign_in_request.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class AuthService {
  Future<Resource<AuthenticatedUserResponse>> signIn(SignInRequest request);
  Future<Resource> forgotPassword(String email);
}