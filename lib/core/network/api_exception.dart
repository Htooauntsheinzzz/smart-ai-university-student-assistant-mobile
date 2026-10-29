/// Base class for errors thrown by the networking and auth layer (DEC-010).
///
/// Each subtype carries a short, user-friendly [userMessage] that can be
/// shown without exposing stack traces, response bodies, SQL errors, or
/// internal error codes. The structured [code] (either an HTTP status or
/// a backend `ApiError.code`) stays available for routing in the
/// controller.
sealed class AuthLayerException implements Exception {
  const AuthLayerException(this.userMessage);

  /// Human-readable message safe to show the user.
  final String userMessage;

  @override
  String toString() => '$runtimeType($userMessage)';
}

/// A response the backend returned with a status outside the 2xx range.
class ApiException extends AuthLayerException {
  const ApiException({
    required this.statusCode,
    required this.code,
    required String userMessage,
  }) : super(userMessage);

  /// HTTP status code (401, 403, 423, 429, …).
  final int statusCode;

  /// Backend error code (e.g. `INVALID_STUDENT_CREDENTIALS`), or `null`
  /// when the response body did not include one.
  final String? code;
}

/// A request that never reached the backend (no connection, DNS failure,
/// timeout, cancelled).
class NetworkException extends AuthLayerException {
  const NetworkException(super.userMessage);
}

/// A response whose body did not match the expected shape (missing
/// fields, wrong types, invalid JSON).
class MalformedResponseException extends AuthLayerException {
  const MalformedResponseException()
    : super('Unable to sign in right now. Please try again later.');
}

/// Hard-wired login error messages (spec section 13). Kept in one place so
/// tests and widgets reference the same strings.
abstract final class AuthMessages {
  static const String invalidCredentials = 'Invalid email or password.';
  static const String accountNotActive =
      'Your student account is not active. Please contact the registrar.';
  static const String accountLocked =
      'Your account is temporarily locked. Please try again later.';
  static const String tooManyRequests =
      'Too many sign-in attempts. Please wait a minute and try again.';
  static const String serviceUnavailable =
      'Sign-in is temporarily unavailable. Please try again later.';
  static const String serverFailure =
      'Unable to sign in right now. Please try again later.';
  static const String noConnection =
      'Unable to connect. Check your connection and try again.';
  static const String timeout = 'The request timed out. Please try again.';
  static const String validation = 'The information provided is not correct.';
  static const String sessionExpired =
      'Your session expired. Please sign in again.';
  static const String passwordChangeRequired =
      'You must change your password before continuing. Please contact your administrator.';
  static const String generic = 'Something went wrong. Please try again.';
}
