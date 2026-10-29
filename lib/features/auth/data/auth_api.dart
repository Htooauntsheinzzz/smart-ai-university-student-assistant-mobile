import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'models/login_response.dart';

/// Student authentication endpoints exposed by the backend (DEC-010).
///
/// The abstract class decouples controllers from Dio so tests can swap
/// in a fake without wiring an HTTP mock.
abstract class AuthApi {
  Future<AuthSession> login({
    required String universityEmail,
    required String password,
  });

  Future<AuthSession> refresh({required String refreshToken});

  Future<void> logout({bool allDevices = false});
}

/// Default implementation that calls the real Spring Boot backend.
class HttpAuthApi implements AuthApi {
  HttpAuthApi(this._dio);
  final Dio _dio;

  static const String _login = '/api/v1/student/auth/login';
  static const String _refresh = '/api/v1/student/auth/refresh';
  static const String _logout = '/api/v1/student/auth/logout';

  @override
  Future<AuthSession> login({
    required String universityEmail,
    required String password,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _login,
        data: <String, String>{
          'universityEmail': universityEmail,
          'password': password,
        },
        options: Options(extra: {kSkipAuthHeaderExtra: true}),
      );
      return _parseSession(response);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<AuthSession> refresh({required String refreshToken}) async {
    try {
      final response = await _dio.post<dynamic>(
        _refresh,
        data: <String, String>{'refreshToken': refreshToken},
        options: Options(extra: {kSkipAuthHeaderExtra: true}),
      );
      return _parseSession(response);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> logout({bool allDevices = false}) async {
    try {
      await _dio.post<void>(
        _logout,
        queryParameters: {'allDevices': allDevices.toString()},
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  AuthSession _parseSession(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const MalformedResponseException();
    }
    return AuthSession.fromJson(body);
  }
}
