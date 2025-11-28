import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class GeocodingService {
  final Logger _logger = Logger();
  final Dio _dio = Dio();

  static String get _googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Obtiene la dirección aproximada a partir de coordenadas (reverse geocoding)
  Future<String?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      _logger.i('🌍 Obteniendo dirección para: $latitude, $longitude');

      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': _googleMapsApiKey,
          'language': 'es', // Español
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final firstResult = results[0] as Map<String, dynamic>;
          final formattedAddress = firstResult['formatted_address'] as String?;

          if (formattedAddress != null) {
            _logger.i('✅ Dirección encontrada: $formattedAddress');
            return formattedAddress;
          }
        }
      }

      _logger.w('⚠️ No se encontró dirección para las coordenadas');
      return null;
    } catch (e) {
      _logger.e('❌ Error al obtener dirección: $e');
      return null;
    }
  }

  /// Obtiene una dirección corta (calle y número) sin país/ciudad
  Future<String?> getShortAddress({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': _googleMapsApiKey,
          'language': 'es',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          // Buscar el resultado con tipo 'street_address' o 'route'
          for (final result in results) {
            final types = result['types'] as List<dynamic>?;
            if (types != null &&
                (types.contains('street_address') || types.contains('route'))) {
              final addressComponents = result['address_components'] as List<dynamic>?;

              if (addressComponents != null) {
                String? route;
                String? streetNumber;

                for (final component in addressComponents) {
                  final types = component['types'] as List<dynamic>?;
                  if (types != null) {
                    if (types.contains('route')) {
                      route = component['long_name'] as String?;
                    }
                    if (types.contains('street_number')) {
                      streetNumber = component['long_name'] as String?;
                    }
                  }
                }

                if (route != null) {
                  return streetNumber != null ? '$route $streetNumber' : route;
                }
              }
            }
          }

          // Si no se encuentra street_address, usar el primer resultado
          final firstResult = results[0] as Map<String, dynamic>;
          final formattedAddress = firstResult['formatted_address'] as String?;
          
          // Extraer solo la primera línea (generalmente la calle)
          if (formattedAddress != null) {
            final parts = formattedAddress.split(',');
            return parts.isNotEmpty ? parts[0].trim() : formattedAddress;
          }
        }
      }

      return null;
    } catch (e) {
      _logger.e('❌ Error al obtener dirección corta: $e');
      return null;
    }
  }
}
