import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_keys.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) {
    return _storage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) {
    return _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> saveSessionId(String sessionId) {
    return _storage.write(key: StorageKeys.sessionId, value: sessionId);
  }

  Future<String?> getSessionId() {
    return _storage.read(key: StorageKeys.sessionId);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.sessionId);
  }
}
