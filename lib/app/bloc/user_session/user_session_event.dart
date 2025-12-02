import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:waste_track_driver_app/entities/user_profile/user_profile.dart';

sealed class UserSessionEvent extends Equatable {
  const UserSessionEvent();

  @override
  List<Object?> get props => [];
}

final class LoadUserSession extends UserSessionEvent {
  const LoadUserSession({
    required this.userId,
  });

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class RefreshUserProfile extends UserSessionEvent {
  const RefreshUserProfile();
}

final class UpdateUserProfile extends UserSessionEvent {
  const UpdateUserProfile({
    required this.userProfile,
  });

  final UserProfile userProfile;

  @override
  List<Object?> get props => [userProfile];
}

final class ClearUserSession extends UserSessionEvent {
  const ClearUserSession();
}

class SaveProfileChanges extends UserSessionEvent {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final File? newPhotoFile;

  const SaveProfileChanges({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.newPhotoFile,
  });
}

class PerformLogout extends UserSessionEvent {
  const PerformLogout();
}