import '../../../../core/network/api_exception.dart';
import 'student_user.dart';

/// Successful response body of `/api/v1/student/auth/login` and
/// `/api/v1/student/auth/refresh` (DEC-010). Both endpoints return the
/// same shape, so one model serves both.
class AuthSession {
  const AuthSession({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    required this.refreshExpiresIn,
    required this.forcePasswordChange,
    required this.user,
  });

  /// Always `"Bearer"` today; kept as a field in case the server
  /// returns another scheme in the future.
  final String tokenType;
  final String accessToken;

  /// Access-token lifetime in seconds (15 minutes by backend default).
  final int expiresIn;
  final String refreshToken;

  /// Refresh-token lifetime in seconds (7 days by backend default).
  final int refreshExpiresIn;

  /// Server-side flag that the student must change their password
  /// before using any protected endpoint except `/me`, `change-password`
  /// and `/logout`.
  final bool forcePasswordChange;

  final StudentUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    try {
      final rawUser = json['user'];
      if (rawUser is! Map<String, dynamic>) {
        throw const MalformedResponseException();
      }
      return AuthSession(
        tokenType: _requireString(json, 'tokenType'),
        accessToken: _requireString(json, 'accessToken'),
        expiresIn: _requireInt(json, 'expiresIn'),
        refreshToken: _requireString(json, 'refreshToken'),
        refreshExpiresIn: _requireInt(json, 'refreshExpiresIn'),
        forcePasswordChange: _requireBool(json, 'forcePasswordChange'),
        user: StudentUser.fromJson(rawUser),
      );
    } on MalformedResponseException {
      rethrow;
    } catch (_) {
      throw const MalformedResponseException();
    }
  }
}

String _requireString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw const MalformedResponseException();
}

int _requireInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const MalformedResponseException();
}

bool _requireBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is bool) return value;
  throw const MalformedResponseException();
}
