import 'package:dio/dio.dart';

import '../../features/auth/data/token_store.dart';
import 'api_exception.dart';

/// A key placed in `Options.extra` to mark a request as unauthenticated
/// (login, refresh). The interceptor skips attaching the access token for
/// requests carrying this key.
const String kSkipAuthHeaderExtra = 'auth.skip';

/// Thin wrapper around [Dio] with sensible timeouts, a request
/// interceptor that attaches the current access token, and uniform
/// mapping of HTTP failures to [AuthLayerException] subtypes (DEC-010).
class ApiClient {
  ApiClient({required Uri baseUrl, required this.tokenStore, Dio? inner})
    : dio = inner ?? _defaultDio(baseUrl) {
    dio.interceptors.add(_AccessTokenInterceptor(tokenStore));
  }

  final Dio dio;
  final TokenStore tokenStore;

  static Dio _defaultDio(Uri baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl.toString(),
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        contentType: 'application/json',
        // Let any 4xx / 5xx surface through `DioException`; we need
        // the body to read the backend's `ApiError.code`.
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
  }
}

/// Attaches `Authorization: Bearer <access-token>` to protected
/// requests. Requests marked with [kSkipAuthHeaderExtra] (login,
/// refresh) are left untouched.
class _AccessTokenInterceptor extends Interceptor {
  _AccessTokenInterceptor(this.tokens);

  final TokenStore tokens;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final skip = options.extra[kSkipAuthHeaderExtra] == true;
    if (!skip) {
      final token = tokens.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}

/// Translates a [DioException] into one of the [AuthLayerException]
/// types. Returns an [ApiException] when the server answered with a
/// non-2xx status, a [NetworkException] when the request never reached
/// the server, and a [MalformedResponseException] for responses that
/// cannot be parsed by the caller.
AuthLayerException mapDioException(DioException error) {
  final response = error.response;
  if (response != null) {
    final status = response.statusCode ?? 0;
    final body = response.data;
    String? code;
    if (body is Map) {
      final rawCode = body['code'];
      if (rawCode is String && rawCode.isNotEmpty) code = rawCode;
    }
    return ApiException(
      statusCode: status,
      code: code,
      userMessage: _messageForStatus(status, code),
    );
  }
  // Any `*Timeout` enum value (dio ≥ 5.9 adds `transformTimeout`) is
  // treated the same; `cancel` and `badCertificate` have their own
  // mapping; everything else reports as "no connection".
  return switch (error.type) {
    DioExceptionType.cancel => const NetworkException(AuthMessages.generic),
    DioExceptionType.badCertificate => const NetworkException(
      AuthMessages.serviceUnavailable,
    ),
    final DioExceptionType t when t.name.toLowerCase().endsWith('timeout') =>
      const NetworkException(AuthMessages.timeout),
    _ => const NetworkException(AuthMessages.noConnection),
  };
}

String _messageForStatus(int status, String? code) {
  switch (code) {
    case 'INVALID_STUDENT_CREDENTIALS':
      return AuthMessages.invalidCredentials;
    case 'STUDENT_ACCOUNT_NOT_ACTIVE':
      return AuthMessages.accountNotActive;
    case 'STUDENT_ACCOUNT_LOCKED':
      return AuthMessages.accountLocked;
    case 'TOO_MANY_REQUESTS':
      return AuthMessages.tooManyRequests;
    case 'AUTH_SERVICE_UNAVAILABLE':
    case 'AUTH_SESSION_UNAVAILABLE':
      return AuthMessages.serviceUnavailable;
    case 'INVALID_REFRESH_TOKEN':
      return AuthMessages.sessionExpired;
    case 'PASSWORD_CHANGE_REQUIRED':
      return AuthMessages.passwordChangeRequired;
    case 'VALIDATION_ERROR':
      return AuthMessages.validation;
    case 'CONTENT_TOO_LARGE':
      return AuthMessages.validation;
  }
  if (status >= 500) return AuthMessages.serverFailure;
  if (status == 401) return AuthMessages.invalidCredentials;
  if (status == 403) return AuthMessages.accountNotActive;
  if (status == 423) return AuthMessages.accountLocked;
  if (status == 429) return AuthMessages.tooManyRequests;
  if (status == 400) return AuthMessages.validation;
  if (status == 503) return AuthMessages.serviceUnavailable;
  return AuthMessages.generic;
}
