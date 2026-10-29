import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Platform-backed secure storage for the backend-issued refresh token
/// (DEC-010). The access token is kept only in memory, so it is held by
/// [TokenStore]; this file persists only the single value required to
/// restore a session on the next launch.
///
/// The abstract class gives tests an injectable in-memory implementation
/// without touching platform channels.
abstract class SessionStorage {
  /// Returns the persisted refresh token, or `null` when no session has
  /// been saved. May throw when the platform keychain / keystore is
  /// unavailable.
  Future<String?> readRefreshToken();

  /// Overwrites any previously stored refresh token. May throw when the
  /// platform keychain / keystore is unavailable.
  Future<void> writeRefreshToken(String value);

  /// Deletes any previously stored refresh token. Must swallow
  /// not-found-style failures silently.
  Future<void> clearRefreshToken();
}

/// Default implementation backed by `flutter_secure_storage`
/// (Keychain on iOS, EncryptedSharedPreferences on Android).
class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  static const String _refreshKey = 'student_refresh_token.v1';

  @override
  Future<String?> readRefreshToken() async {
    final value = await _storage.read(key: _refreshKey);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  @override
  Future<void> writeRefreshToken(String value) async {
    await _storage.write(key: _refreshKey, value: value);
  }

  @override
  Future<void> clearRefreshToken() async {
    await _storage.delete(key: _refreshKey);
  }
}

/// Volatile implementation used when secure storage is unavailable (for
/// example, in widget tests). Nothing survives a hot restart or app
/// relaunch.
class InMemorySessionStorage implements SessionStorage {
  String? _value;

  @override
  Future<String?> readRefreshToken() async => _value;

  @override
  Future<void> writeRefreshToken(String value) async {
    _value = value;
  }

  @override
  Future<void> clearRefreshToken() async {
    _value = null;
  }
}
