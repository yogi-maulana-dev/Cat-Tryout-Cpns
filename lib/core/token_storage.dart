import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan token Sanctum yang aman (Keychain iOS / Keystore Android).
class TokenStorage {
  static const _key = 'auth_token';
  final FlutterSecureStorage _storage;

  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> save(String token) => _storage.write(key: _key, value: token);

  Future<String?> read() => _storage.read(key: _key);

  Future<void> clear() => _storage.delete(key: _key);
}
