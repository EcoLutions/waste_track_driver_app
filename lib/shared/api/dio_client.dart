import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';
import 'package:waste_track_driver_app/shared/lib/storage/secure_storage_service.dart';
import 'package:waste_track_driver_app/shared/lib/utils/api_exception.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

class DioClient {

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  late final Dio _dio;
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger();
  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // ==================== REQUEST ====================
        onRequest: (options, handler) async {
          // Add JWT token to request headers automatically
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
          _logger.d('Headers: ${options.headers}');
          if (options.data != null) {
            _logger.d('Body: ${options.data}');
          }

          return handler.next(options);
        },

        // ==================== RESPONSE ====================
        onResponse: (response, handler) {
          _logger.i(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          _logger.d('Data: ${response.data}');
          return handler.next(response);
        },

        // ==================== ERROR ====================
        onError: (error, handler) async {
          _logger.e(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
          );
          _logger.e('Message: ${error.message}');
          _logger.e('Data: ${error.response?.data}');

          // Handle unauthorized requests (401)
          if (error.response?.statusCode == 401) {
            await _secureStorage.deleteToken();
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: DioExceptionType.badResponse,
                error: UnauthorizedException(),
              ),
            );
          }

          return handler.next(error);
        },
      ),
    );

    // Log interceptor (for debugging)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => _logger.d(obj),
    ));
  }

  Future<Resource<T>> handleRequest<T>(Future<Response> Function() request, T Function(dynamic data) parser) async {
    try {
      final response = await request();
      final data = parser(response.data);
      return Success(data);
    } on DioException catch (e) {
      final exception = ApiException.fromDioError(e);
      return Failure(
        message: exception.message,
        statusCode: exception.statusCode,
        error: exception.error,
      );
    } catch (e) {
      return Failure(
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }
}