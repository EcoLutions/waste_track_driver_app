import 'package:waste_track_driver_app/entities/user/model/user_role.dart';

class AuthBasicData {
  const AuthBasicData({
    required this.userId,
    required this.token,
    required this.roles,
  });

  final String userId;
  final String token;
  final List<UserRole> roles;

  bool get canAccessDriverApp => roles.any((role) => role.canAccessDriverApp);

  bool get isActive => true;
}