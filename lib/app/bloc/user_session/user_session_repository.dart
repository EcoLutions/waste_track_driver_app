import 'package:waste_track_driver_app/entities/district/district.dart';
import 'package:waste_track_driver_app/entities/driver/driver.dart';
import 'package:waste_track_driver_app/entities/user/user.dart';
import 'package:waste_track_driver_app/entities/user_profile/user_profile.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class UserSessionRepository {
  Future<Resource<User>> loadUser(String userId);
  Future<Resource<UserProfile>> loadUserProfile(String userId);
  Future<Resource<District>> loadDistrict(String districtId);
  Future<Resource<Driver>> loadCurrentDriver();
  Future<Resource<UserSessionData>> loadCompleteSession(String userId);
}

class UserSessionData {
  const UserSessionData({
    required this.user,
    required this.userProfile,
    this.district,
    this.driver,
  });

  final User user;
  final UserProfile userProfile;
  final District? district;
  final Driver? driver;
}