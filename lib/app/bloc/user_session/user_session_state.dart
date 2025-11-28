import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waste_track_driver_app/entities/district/district.dart';
import 'package:waste_track_driver_app/entities/driver/driver.dart';
import 'package:waste_track_driver_app/entities/user/user.dart';
import 'package:waste_track_driver_app/entities/user_profile/user_profile.dart';

part 'user_session_state.freezed.dart';

@freezed
sealed class UserSessionState with _$UserSessionState {
  const factory UserSessionState.initial() = UserSessionInitial;

  const factory UserSessionState.loading() = UserSessionLoading;

  const factory UserSessionState.loaded({
    required User user,
    required UserProfile userProfile,
    District? district,
    Driver? driver,
  }) = UserSessionLoaded;

  const factory UserSessionState.error(String message) = UserSessionError;
}

extension UserSessionStateX on UserSessionState {
  bool get isLoaded => this is UserSessionLoaded;

  bool get isLoading => this is UserSessionLoading;

  User? get user => switch (this) {
    UserSessionLoaded(user: final u) => u,
    _ => null,
  };

  Driver? get driver => switch (this) {
    UserSessionLoaded(driver: final d) => d,
    _ => null,
  };

  UserProfile? get userProfile => switch (this) {
    UserSessionLoaded(userProfile: final p) => p,
    _ => null,
  };

  District? get district => switch (this) {
    UserSessionLoaded(district: final d) => d,
    _ => null,
  };

  String? get userName => user?.username;

  String? get userEmail => user?.email;

  String? get photoUrl => userProfile?.hasTemporalPhotoUrl == true
      ? userProfile?.temporalPhotoUrl
      : userProfile?.photoPath;

  String? get districtName => district?.name;

  bool get hasDistrict => district != null;
}