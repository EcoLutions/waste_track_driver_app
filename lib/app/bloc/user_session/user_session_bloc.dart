import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_event.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_repository.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_state.dart';
import 'package:waste_track_driver_app/entities/district/model/entities/district.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class UserSessionBloc extends Bloc<UserSessionEvent, UserSessionState> {
  UserSessionBloc({
    required UserSessionRepository userSessionRepository,
  })  : _userSessionRepository = userSessionRepository,
        super(const UserSessionState.initial()) {
    on<LoadUserSession>(_onLoadUserSession);
    on<RefreshUserProfile>(_onRefreshUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<ClearUserSession>(_onClearUserSession);
  }

  final UserSessionRepository _userSessionRepository;
  final Logger _logger = Logger();

  Future<void> _onLoadUserSession(LoadUserSession event, Emitter<UserSessionState> emit,) async {
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
        ));
        break;

      case Failure(message: final msg):
        _logger.e('Error al cargar sesión: $msg');
        emit(UserSessionState.error(msg));
        break;
    }
  }

  Future<void> _onRefreshUserProfile(RefreshUserProfile event, Emitter<UserSessionState> emit,) async {
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

        // Recargar distrito si cambió
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
        ));
        break;

      case Failure(message: final msg):
        _logger.e('Error al refrescar perfil: $msg');
        emit(UserSessionState.error(msg));
        break;
    }
  }

  Future<void> _onUpdateUserProfile(UpdateUserProfile event, Emitter<UserSessionState> emit,) async {
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
    ));
  }

  Future<void> _onClearUserSession(ClearUserSession event, Emitter<UserSessionState> emit,) async {
    _logger.i('Limpiando sesión de usuario');
    emit(const UserSessionState.initial());
  }
}