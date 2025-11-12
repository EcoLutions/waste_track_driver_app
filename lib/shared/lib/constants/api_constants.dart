class ApiConstants {
  ApiConstants._();
  static const String baseUrl = 'http://localhost:8080/api/v1';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String authEndpoint = '/authentication';
  static const String usersEndpoint = '/users';

  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
}