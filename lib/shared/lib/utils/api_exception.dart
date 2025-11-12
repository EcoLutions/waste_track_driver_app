class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.error,
  });

  factory ApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      String message = 'Error desconocido';
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? data['error'] ?? 'Error del servidor';
      }

      return ApiException(
        message: message,
        statusCode: statusCode,
        error: data,
      );
    }

    if (error.type.toString().contains('connectionTimeout') ||
        error.type.toString().contains('receiveTimeout')) {
      return ApiException(
        message: 'Tiempo de espera agotado. Verifica tu conexión.',
      );
    }

    return ApiException(
      message: 'Error de conexión. Verifica tu internet.',
      error: error,
    );
  }

  final String message;
  final int? statusCode;
  final dynamic error;

  @override
  String toString() => 'ApiException(message: $message, statusCode: $statusCode)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(
    message: message ?? 'No autorizado. Inicia sesión nuevamente.',
    statusCode: 401,
  );
}

class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(
    message: message ?? 'Recurso no encontrado.',
    statusCode: 404,
  );
}

class BadRequestException extends ApiException {
  BadRequestException({String? message})
      : super(
    message: message ?? 'Solicitud inválida.',
    statusCode: 400,
  );
}

class ServerException extends ApiException {
  ServerException({String? message})
      : super(
    message: message ?? 'Error del servidor. Intenta más tarde.',
    statusCode: 500,
  );
}