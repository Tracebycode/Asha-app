import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service class for securely handling the JWT (JSON Web Token).
/// It uses flutter_secure_storage to save the token to the device's
/// Keychain (iOS) or Keystore (Android).
class SecureStorageService {
  // Create a private instance of the storage.
  final _storage = const FlutterSecureStorage();

  // Define a constant key for storing the token. This prevents typos.
  static const _tokenKey = 'auth_token';

  /// Saves the authentication token securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the authentication token from secure storage.
  /// Returns null if the token doesn't exist.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Deletes the authentication token from secure storage.
  /// This is used during logout.
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
