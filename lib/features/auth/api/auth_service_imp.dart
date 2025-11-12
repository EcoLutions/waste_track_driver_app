import 'package:waste_track_driver_app/features/auth/api/auth_service.dart';
import 'package:waste_track_driver_app/features/auth/model/authenticated_user_response.dart';
import 'package:waste_track_driver_app/features/auth/model/sign_in_request.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class AuthServiceImpl implements AuthService {
  AuthServiceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<Resource<AuthenticatedUserResponse>> signIn(SignInRequest request,) async {
    return _dioClient.handleRequest(
          () => _dioClient.dio.post('${ApiConstants.authEndpoint}/sign-in', data: request.toJson(),),
          (data) => AuthenticatedUserResponse.fromJson(data as Map<String, dynamic>,),
    );
  }
}