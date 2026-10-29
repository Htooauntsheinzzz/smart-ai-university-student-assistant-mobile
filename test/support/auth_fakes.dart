import 'dart:async';

import 'package:smart_ai_university_student_assistant/core/network/api_exception.dart';
import 'package:smart_ai_university_student_assistant/features/auth/data/auth_api.dart';
import 'package:smart_ai_university_student_assistant/features/auth/data/models/login_response.dart';
import 'package:smart_ai_university_student_assistant/features/auth/data/models/student_user.dart';

/// A hand-written in-memory [AuthApi] used by widget and controller
/// tests (DEC-010). Tests enqueue the response (or exception) each
/// endpoint should return next and inspect the recorded calls.
class FakeAuthApi implements AuthApi {
  final List<RecordedLoginCall> loginCalls = [];
  final List<RecordedRefreshCall> refreshCalls = [];
  final List<RecordedLogoutCall> logoutCalls = [];

  final List<FutureOr<AuthSession> Function()> _nextLogin = [];
  final List<FutureOr<AuthSession> Function()> _nextRefresh = [];
  final List<FutureOr<void> Function()> _nextLogout = [];

  /// Add [session] as the next successful login response.
  void queueLoginSuccess(AuthSession session) {
    _nextLogin.add(() => session);
  }

  /// Add [error] (any `AuthLayerException` or arbitrary error) as the
  /// next login failure.
  void queueLoginError(Object error) {
    _nextLogin.add(() => throw error);
  }

  /// Hold the next login until [completer] completes.
  void queueLoginFuture(Future<AuthSession> future) {
    _nextLogin.add(() => future);
  }

  void queueRefreshSuccess(AuthSession session) {
    _nextRefresh.add(() => session);
  }

  void queueRefreshError(Object error) {
    _nextRefresh.add(() => throw error);
  }

  void queueLogoutSuccess() {
    _nextLogout.add(() {});
  }

  void queueLogoutError(Object error) {
    _nextLogout.add(() => throw error);
  }

  @override
  Future<AuthSession> login({
    required String universityEmail,
    required String password,
  }) async {
    loginCalls.add(RecordedLoginCall(universityEmail, password));
    if (_nextLogin.isEmpty) {
      throw StateError('No login response queued.');
    }
    final response = _nextLogin.removeAt(0)();
    return await Future.value(response);
  }

  @override
  Future<AuthSession> refresh({required String refreshToken}) async {
    refreshCalls.add(RecordedRefreshCall(refreshToken));
    if (_nextRefresh.isEmpty) {
      throw StateError('No refresh response queued.');
    }
    final response = _nextRefresh.removeAt(0)();
    return await Future.value(response);
  }

  @override
  Future<void> logout({bool allDevices = false}) async {
    logoutCalls.add(RecordedLogoutCall(allDevices));
    if (_nextLogout.isEmpty) return;
    final response = _nextLogout.removeAt(0)();
    await Future.value(response);
  }
}

class RecordedLoginCall {
  const RecordedLoginCall(this.email, this.password);
  final String email;
  final String password;
}

class RecordedRefreshCall {
  const RecordedRefreshCall(this.refreshToken);
  final String refreshToken;
}

class RecordedLogoutCall {
  const RecordedLogoutCall(this.allDevices);
  final bool allDevices;
}

/// Build a canned [StudentUser] for test fixtures. Any field can be
/// overridden through named parameters.
StudentUser buildStudent({
  int id = 1,
  String studentCode = '6512345678',
  String universityEmail = 'test.student@rsu.ac.th',
  String firstName = 'Shein',
  String lastName = 'Htoo',
  String accountStatus = 'ACTIVE',
  bool forcePasswordChange = false,
  String? programName,
  int? academicYear,
}) {
  return StudentUser(
    id: id,
    studentCode: studentCode,
    universityEmail: universityEmail,
    firstName: firstName,
    lastName: lastName,
    accountStatus: accountStatus,
    forcePasswordChange: forcePasswordChange,
    programName: programName,
    academicYear: academicYear,
  );
}

/// Build a canned [AuthSession] holding [user] (or the default
/// student). Token values are predictable so tests can assert on them.
AuthSession buildSession({
  StudentUser? user,
  String accessToken = 'access-token-1',
  String refreshToken = 'refresh-token-1',
  int expiresIn = 900,
  int refreshExpiresIn = 604800,
  bool forcePasswordChange = false,
}) {
  final effectiveUser = user ?? buildStudent();
  return AuthSession(
    tokenType: 'Bearer',
    accessToken: accessToken,
    expiresIn: expiresIn,
    refreshToken: refreshToken,
    refreshExpiresIn: refreshExpiresIn,
    forcePasswordChange: forcePasswordChange,
    user: effectiveUser,
  );
}

/// Convenience factories for the exception types [ApiClient] produces.
abstract final class TestApiErrors {
  static ApiException invalidCredentials() => const ApiException(
    statusCode: 401,
    code: 'INVALID_STUDENT_CREDENTIALS',
    userMessage: AuthMessages.invalidCredentials,
  );

  static ApiException accountLocked() => const ApiException(
    statusCode: 423,
    code: 'STUDENT_ACCOUNT_LOCKED',
    userMessage: AuthMessages.accountLocked,
  );

  static ApiException tooManyRequests() => const ApiException(
    statusCode: 429,
    code: 'TOO_MANY_REQUESTS',
    userMessage: AuthMessages.tooManyRequests,
  );

  static ApiException sessionExpired() => const ApiException(
    statusCode: 401,
    code: 'INVALID_REFRESH_TOKEN',
    userMessage: AuthMessages.sessionExpired,
  );

  static NetworkException noConnection() =>
      const NetworkException(AuthMessages.noConnection);

  static NetworkException timeout() =>
      const NetworkException(AuthMessages.timeout);
}
