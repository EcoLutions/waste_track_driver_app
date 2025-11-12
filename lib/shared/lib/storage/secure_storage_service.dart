import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:waste_track_driver_app/shared/lib/constants/api_constants.dart';

class SecureStorageService {
  SecureStorageService(this._storage);
  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: ApiConstants.tokenKey,
      value: token,
    );
  }

  Future<String?> getToken() async {
    return _storage.read(key: ApiConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: ApiConstants.tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> get(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}