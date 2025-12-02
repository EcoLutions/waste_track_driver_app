import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_event.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_repository.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_state.dart';
import 'package:waste_track_driver_app/entities/district/model/entities/district.dart';
import 'package:waste_track_driver_app/entities/user_profile/api/repositories/user_profile_repository.dart';
import 'package:waste_track_driver_app/features/authentication/api/auth_repository.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class UserSessionBloc extends Bloc<UserSessionEvent, UserSessionState> {
  final UserSessionRepository _userSessionRepository;
  final UserProfileRepository _userProfileRepository;
  final AuthRepository _authRepository;
  final Logger _logger = Logger();

  UserSessionBloc({
    required UserSessionRepository userSessionRepository,
    required UserProfileRepository userProfileRepository,
    required AuthRepository authRepository,
  })  : _userSessionRepository = userSessionRepository,
        _userProfileRepository = userProfileRepository,
        _authRepository = authRepository,
        super(const UserSessionState.initial()) {
    on<LoadUserSession>(_onLoadUserSession);
    on<RefreshUserProfile>(_onRefreshUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<ClearUserSession>(_onClearUserSession);
    on<SaveProfileChanges>(_onSaveProfileChanges);
    on<PerformLogout>(_onPerformLogout);
  }

  Future<void> _onLoadUserSession(
      LoadUserSession event,
      Emitter<UserSessionState> emit,
      ) async {
    _logger.i('Cargando sesión de usuario: ${event.userId}');
    emit(const UserSessionState.loading());

    final result = await _userSessionRepository.loadCompleteSession(event.userId);

    switch (result) {
      case Success(data: final sessionData):
        _logger.i('Sesión cargada exitosamente para: ${sessionData.user.username}');
        emit(UserSessionState.loaded(
          user: sessionData.user,
          userProfile: sessionData.userProfile,
          district: sessionData.district,
          driver: sessionData.driver,
        ));
        break;

      case Failure(message: final msg):
        _logger.e('Error al cargar sesión: $msg');
        emit(UserSessionState.error(msg));
        break;
    }
  }

  Future<void> _onRefreshUserProfile(
      RefreshUserProfile event,
      Emitter<UserSessionState> emit,
      ) async {
    final currentState = state;
    if (currentState is! UserSessionLoaded) {
      _logger.w('No hay sesión cargada para refrescar');
      return;
    }

    _logger.i('Refrescando perfil de usuario: ${currentState.user.id}');

    final profileResult = await _userSessionRepository.loadUserProfile(
      currentState.user.id,
    );

    switch (profileResult) {
      case Success(data: final profile):
        _logger.i('Perfil refrescado exitosamente');

        District? district;
        if (profile.hasDistrictId) {
          final districtResult = await _userSessionRepository.loadDistrict(
            profile.districtId!,
          );
          if (districtResult is Success) {
            district = districtResult.dataOrNull;
          }
        }

        emit(UserSessionState.loaded(
          user: currentState.user,
          userProfile: profile,
          district: district,
          driver: currentState.driver,
        ));
        break;

      case Failure(message: final msg):
        _logger.e('Error al refrescar perfil: $msg');
        emit(UserSessionState.error(msg));
        break;
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event,
      Emitter<UserSessionState> emit,
      ) async {
    final currentState = state;
    if (currentState is! UserSessionLoaded) {
      _logger.w('No hay sesión cargada para actualizar');
      return;
    }

    _logger.i('Actualizando perfil localmente');

    emit(UserSessionState.loaded(
      user: currentState.user,
      userProfile: event.userProfile,
      district: currentState.district,
      driver: currentState.driver,
    ));
  }

  Future<void> _onClearUserSession(
      ClearUserSession event,
      Emitter<UserSessionState> emit,
      ) async {
    _logger.i('Limpiando sesión de usuario');
    emit(const UserSessionState.initial());
  }

  Future<void> _onSaveProfileChanges(
      SaveProfileChanges event,
      Emitter<UserSessionState> emit,
      ) async {
    final currentState = state;
    if (currentState is! UserSessionLoaded) return;

    // CORRECCIÓN: Garantizamos que sea String (si es null, usamos vacío)
    String photoPath = currentState.userProfile?.photoPath ?? "";

    try {
      // 1. Si hay nueva foto, subirla
      if (event.newPhotoFile != null) {
        final photoResult = await _userProfileRepository.uploadPhoto(event.newPhotoFile!);

        if (photoResult is Success) {
          // Aseguramos que el dato sea String
          photoPath = (photoResult as Success).data;
        } else {
          _logger.w("Falló la subida de imagen");
        }
      }

      // 2. Actualizar UserProfile
      if (currentState.userProfile != null) {
        final updatedProfile = currentState.userProfile!.copyWith(
          phoneNumber: event.phoneNumber ?? currentState.userProfile!.phoneNumber,
          photoPath: photoPath, // Ahora pasamos una variable String segura
        );

        final updateResult = await _userProfileRepository.update(updatedProfile.id, updatedProfile);

        if (updateResult is Success) {
          _logger.i("Perfil actualizado correctamente");
          add(LoadUserSession(userId: currentState.user.id));
        } else {
          _logger.e("Error al actualizar datos del perfil en backend");
          emit(UserSessionState.error((updateResult as Failure).message));
        }
      }
    } catch (e) {
      _logger.e("Excepción al guardar perfil: $e");
      emit(const UserSessionState.error("Error inesperado al procesar cambios"));
    }
  }

  Future<void> _onPerformLogout(
      PerformLogout event,
      Emitter<UserSessionState> emit,
      ) async {
    try {
      await _authRepository.logout();
    } catch (e) {
      _logger.e("Error durante logout: $e");
    }
    emit(const UserSessionState.initial());
  }
}