import 'package:dio/dio.dart';
import 'package:waste_track_driver_app/shared/api/dio_client.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class BaseService {
  BaseService(this._dioClient, this._baseEndpoint);
  final DioClient _dioClient;
  final String _baseEndpoint;

  Dio get dio => _dioClient.dio;

  String get resourcePath => _baseEndpoint;

  String buildPath(String path) => '$resourcePath$path';

  Future<Resource<T>> get<T>(String path, T Function(dynamic data) parser, { Map<String, dynamic>? queryParameters, }) async {
    return _dioClient.handleRequest(
          () => dio.get(
        buildPath(path),
        queryParameters: queryParameters,
      ),
      parser,
    );
  }

  Future<Resource<T>> post<T>(String path, T Function(dynamic data) parser, { dynamic data, Map<String, dynamic>? queryParameters,}) async {
    return _dioClient.handleRequest(
          () => dio.post(
        buildPath(path),
        data: data,
        queryParameters: queryParameters,
      ),
      parser,
    );
  }

  Future<Resource<T>> put<T>(String path, T Function(dynamic data) parser, { dynamic data, Map<String, dynamic>? queryParameters,}) async {
    return _dioClient.handleRequest(
          () => dio.put(
        buildPath(path),
        data: data,
        queryParameters: queryParameters,
      ),
      parser,
    );
  }

  Future<Resource<T>> delete<T>(String path, T Function(dynamic data) parser, { Map<String, dynamic>? queryParameters,}) async {
    return _dioClient.handleRequest(
          () => dio.delete(
        buildPath(path),
        queryParameters: queryParameters,
      ),
      parser,
    );
  }

  Future<Resource<T>> patch<T>(String path, T Function(dynamic data) parser, { dynamic data, Map<String, dynamic>? queryParameters,}) async {
    return _dioClient.handleRequest(
          () => dio.patch(
        buildPath(path),
        data: data,
        queryParameters: queryParameters,
      ),
      parser,
    );
  }
}