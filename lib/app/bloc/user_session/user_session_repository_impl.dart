import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/app/bloc/user_session/user_session_repository.dart';
import 'package:waste_track_driver_app/entities/district/district.dart';
import 'package:waste_track_driver_app/entities/driver/driver.dart';
import 'package:waste_track_driver_app/entities/user/user.dart';
import 'package:waste_track_driver_app/entities/user_profile/user_profile.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class UserSessionRepositoryImpl implements UserSessionRepository {
  UserSessionRepositoryImpl({
    required UserService userService,
    required UserProfileService userProfileService,
    required DistrictService districtService,
    required DriverRepository driverRepository,
  })  : _userService = userService,
        _userProfileService = userProfileService,
        _districtService = districtService,
        _driverRepository = driverRepository;

  final UserService _userService;
  final UserProfileService _userProfileService;
  final DistrictService _districtService;
  final DriverRepository _driverRepository;
  final Logger _logger = Logger();

  @override
  Future<Resource<User>> loadUser(String userId) async {
    _logger.i('Cargando usuario con ID: $userId');

    final result = await _userService.getCurrentUser();

    return switch (result) {
      Success(data: final userDto) => Success(userDto.toDomain()),
      Failure(message: final msg, statusCode: final code) => Failure(
        message: msg,
        statusCode: code,
      ),
    };
  }

  @override
  Future<Resource<UserProfile>> loadUserProfile(String userId) async {
    _logger.i('Cargando perfil de usuario para userId: $userId');

    final result = await _userProfileService.getByUserId(userId);

    return switch (result) {
      Success(data: final profileDto) => Success(profileDto.toDomain()),
      Failure(message: final msg, statusCode: final code) => Failure(
        message: msg,
        statusCode: code,
      ),
    };
  }

  @override
  Future<Resource<District>> loadDistrict(String districtId) async {
    _logger.i('Cargando distrito con ID: $districtId');

    final result = await _districtService.getById(districtId);

    return switch (result) {
      Success(data: final districtDto) => Success(districtDto.toDomain()),
      Failure(message: final msg, statusCode: final code) => Failure(
        message: msg,
        statusCode: code,
      ),
    };
  }

  @override
  Future<Resource<Driver>> loadCurrentDriver() async {
    _logger.i('Cargando driver del usuario autenticado');

    final result = await _driverRepository.getCurrentDriver();

    return switch (result) {
      Success(data: final driver) => Success(driver),
      Failure(message: final msg, statusCode: final code) => Failure(
        message: msg,
        statusCode: code,
      ),
    };
  }

  @override
  Future<Resource<UserSessionData>> loadCompleteSession(String userId) async {
    _logger.i('Cargando sesión completa para userId: $userId');

    // Step 1: Load user
    final userResult = await loadUser(userId);

    switch (userResult) {
      case Failure(message: final msg, statusCode: final code):
        _logger.e('Error al cargar usuario: $msg');
        return Failure(message: msg, statusCode: code);
      case Success(data: final user):
      // Step 2: Load user profile
        final profileResult = await loadUserProfile(userId);

        switch (profileResult) {
          case Success(data: final userProfile):
            _logger.i('Perfil de usuario cargado exitosamente');

            District? district;
            Driver? driver;

            // Step 3: Load district if user has one
            if (userProfile.hasDistrictId) {
              _logger.i('Cargando distrito con ID: ${userProfile.districtId}');
              final districtResult = await loadDistrict(userProfile.districtId!);

              switch (districtResult) {
                case Success(data: final d):
                  district = d;
                  _logger.i('Distrito cargado exitosamente: ${district.name}');
                  break;
                case Failure(message: final msg):
                  _logger.w('No se pudo cargar el distrito: $msg');
                  break;
              }
            } else {
              _logger.i('Usuario no tiene distrito asignado');
            }

            // Step 4: Load driver
            _logger.i('Cargando driver del usuario autenticado');
            final driverResult = await loadCurrentDriver();

            switch (driverResult) {
              case Success(data: final d):
                driver = d;
                _logger.i('Driver cargado exitosamente: ${driver.id}');
                break;
              case Failure(message: final msg):
                _logger.w('No se pudo cargar el driver: $msg');
                _logger.w('Continuando sin driver - la app funcionará de forma limitada');
                // No fallar aquí, continuar sin driver
                break;
            }

            return Success(UserSessionData(
              user: user,
              userProfile: userProfile,
              district: district,
              driver: driver,
            ));

          case Failure(message: final msg, statusCode: final code):
            _logger.e('No se pudo cargar el perfil de usuario: $msg');
            return Failure(
              message: 'No se pudo cargar el perfil: $msg',
              statusCode: code,
            );
        }
    }
  }
}