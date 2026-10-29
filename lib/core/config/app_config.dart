import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

/// Backend API base URL and other startup configuration (DEC-010).
///
/// The value comes from the compile-time environment variable
/// `API_BASE_URL`, passed with
/// `--dart-define=API_BASE_URL=https://api.example.com` for a real
/// deployment. Release builds must set it to an `https` URL and fail
/// clearly otherwise.
///
/// In debug and profile builds the default points at the Spring Boot
/// backend running on this machine (`http://localhost:8080` on iOS
/// Simulators and macOS, `http://10.0.2.2:8080` on Android emulators,
/// which maps to the host's loopback). To run on a physical phone, pass
/// `--dart-define=API_BASE_URL=http://<mac-lan-ip>:8080`.
class AppConfig {
  const AppConfig._({required this.apiBaseUrl});

  /// Fully-qualified base URL, with a trailing slash. API paths are
  /// resolved against this URL (`'/api/v1/student/auth/login'`).
  final Uri apiBaseUrl;

  static const String _rawApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Build the configuration from compile-time defines. Throws a
  /// [StateError] when the configuration is missing or malformed, so a
  /// misconfigured release build fails at startup instead of silently
  /// talking to the wrong server.
  factory AppConfig.fromEnvironment() {
    final rawValue = _rawApiBaseUrl.trim();
    final raw = rawValue.isEmpty ? _defaultDevBaseUrl() : rawValue;
    final parsed = Uri.tryParse(raw);
    if (parsed == null || !parsed.hasAuthority) {
      throw StateError(
        'API_BASE_URL is missing or malformed. '
        'Pass --dart-define=API_BASE_URL=<url>. Got "$raw".',
      );
    }
    if (parsed.scheme != 'http' && parsed.scheme != 'https') {
      throw StateError('API_BASE_URL must use http or https. Got "$parsed".');
    }
    // Plain HTTP is for local development only. Release builds must use
    // HTTPS so credentials are never sent over an unencrypted channel.
    if (!kDebugMode && parsed.scheme != 'https') {
      throw StateError(
        'API_BASE_URL must use HTTPS in release/profile builds. Got "$parsed".',
      );
    }
    final normalizedPath = parsed.path.isEmpty || parsed.path.endsWith('/')
        ? parsed.path
        : '${parsed.path}/';
    final normalized = parsed.replace(path: normalizedPath);
    return AppConfig._(apiBaseUrl: normalized);
  }

  static String _defaultDevBaseUrl() {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }
}
