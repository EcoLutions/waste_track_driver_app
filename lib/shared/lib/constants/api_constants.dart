import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();
  static String get baseUrl {
    if (kDebugMode) {
      // Development (Android Emulator)
      return 'http://10.0.2.2:8080/api/v1';
    } else {
      // Production
      return 'https://api.ecolucions.com/api/v1';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String authEndpoint = '/authentication';
  static const String usersEndpoint = '/users';

  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
}