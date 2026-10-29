import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_ai_university_student_assistant/core/network/api_exception.dart';
import 'package:smart_ai_university_student_assistant/core/storage/session_storage.dart';
import 'package:smart_ai_university_student_assistant/features/auth/data/token_store.dart';
import 'package:smart_ai_university_student_assistant/features/auth/presentation/controllers/auth_controller.dart';

import 'support/auth_fakes.dart';

/// Secure-storage double that fails every read/write; used to verify
/// the controller still signs in when the keychain is unavailable.
class _FailingSessionStorage implements SessionStorage {
  int reads = 0;
  int writes = 0;
  int clears = 0;

  @override
  Future<String?> readRefreshToken() async {
    reads++;
    throw Exception('secure storage unavailable');
  }

  @override
  Future<void> writeRefreshToken(String value) async {
    writes++;
    throw Exception('secure storage unavailable');
  }

  @override
  Future<void> clearRefreshToken() async {
    clears++;
    throw Exception('secure storage unavailable');
  }
}

AuthController _buildController({
  required FakeAuthApi api,
  SessionStorage? storage,
  TokenStore? tokens,
}) {
  return AuthController(
    api: api,
    sessionStorage: storage ?? InMemorySessionStorage(),
    tokenStore: tokens ?? TokenStore(),
  );
}

void main() {
  group('AuthController.restore', () {
    test('without a stored token lands on unauthenticated', () async {
      final api = FakeAuthApi();
      final controller = _buildController(api: api);
      await controller.restore();
      expect(controller.status, AuthStatus.unauthenticated);
      expect(controller.user, isNull);
      expect(api.refreshCalls, isEmpty);
    });

    test('with a stored token refreshes and authenticates', () async {
      final api = FakeAuthApi()..queueRefreshSuccess(buildSession());
      final storage = InMemorySessionStorage()
        ..writeRefreshToken('persisted-token');
      final tokens = TokenStore();
      final controller = _buildController(
        api: api,
        storage: storage,
        tokens: tokens,
      );
      await controller.restore();

      expect(controller.status, AuthStatus.authenticated);
      expect(controller.user?.studentCode, '6512345678');
      expect(tokens.accessToken, 'access-token-1');
      expect(api.refreshCalls.single.refreshToken, 'persisted-token');
      // The rotated refresh token must be persisted so the next launch
      // can keep the user signed in.
      expect(await storage.readRefreshToken(), 'refresh-token-1');
    });

    test(
      'expired token is cleared and the user ends up unauthenticated',
      () async {
        final api = FakeAuthApi()
          ..queueRefreshError(TestApiErrors.sessionExpired());
        final storage = InMemorySessionStorage()
          ..writeRefreshToken('persisted-token');
        final controller = _buildController(api: api, storage: storage);
        await controller.restore();

        expect(controller.status, AuthStatus.unauthenticated);
        expect(controller.errorMessage, AuthMessages.sessionExpired);
        expect(await storage.readRefreshToken(), isNull);
      },
    );

    test('network failure keeps the stored token and shows retry', () async {
      final api = FakeAuthApi()
        ..queueRefreshError(TestApiErrors.noConnection());
      final storage = InMemorySessionStorage()
        ..writeRefreshToken('persisted-token');
      final controller = _buildController(api: api, storage: storage);
      await controller.restore();

      expect(controller.status, AuthStatus.initializationError);
      expect(controller.errorMessage, AuthMessages.noConnection);
      expect(await storage.readRefreshToken(), 'persisted-token');

      // Retry: now the network is back, we land on authenticated.
      api.queueRefreshSuccess(buildSession());
      await controller.retryInitialization();
      expect(controller.status, AuthStatus.authenticated);
    });

    test('read failure from secure storage is treated as no session', () async {
      final api = FakeAuthApi();
      final storage = _FailingSessionStorage();
      final controller = _buildController(api: api, storage: storage);
      await controller.restore();

      expect(storage.reads, 1);
      expect(api.refreshCalls, isEmpty);
      expect(controller.status, AuthStatus.unauthenticated);
    });
  });

  group('AuthController.login', () {
    test(
      'successful call authenticates and persists on Keep Me Signed In',
      () async {
        final api = FakeAuthApi()..queueLoginSuccess(buildSession());
        final storage = InMemorySessionStorage();
        final tokens = TokenStore();
        final controller = _buildController(
          api: api,
          storage: storage,
          tokens: tokens,
        );

        await controller.login(
          universityEmail: '  Student@RSU.ac.th  ',
          password: 'P@ssw0rd',
          keepSignedIn: true,
        );

        expect(controller.status, AuthStatus.authenticated);
        expect(controller.user?.universityEmail, 'test.student@rsu.ac.th');
        expect(tokens.accessToken, 'access-token-1');
        expect(tokens.refreshToken, 'refresh-token-1');
        // Email is trimmed before being sent; the password is sent as
        // typed, with no transformation.
        expect(api.loginCalls.single.email, 'Student@RSU.ac.th');
        expect(api.loginCalls.single.password, 'P@ssw0rd');
        expect(await storage.readRefreshToken(), 'refresh-token-1');
      },
    );

    test(
      'with Keep Me Signed In off, no refresh token survives on disk',
      () async {
        final api = FakeAuthApi()..queueLoginSuccess(buildSession());
        final storage = InMemorySessionStorage()
          ..writeRefreshToken('left-over');
        final tokens = TokenStore();
        final controller = _buildController(
          api: api,
          storage: storage,
          tokens: tokens,
        );

        await controller.login(
          universityEmail: 'student@rsu.ac.th',
          password: 'secret',
          keepSignedIn: false,
        );

        expect(controller.status, AuthStatus.authenticated);
        expect(tokens.refreshToken, 'refresh-token-1');
        // The pre-existing token must be wiped so a fresh launch cannot
        // restore the old session.
        expect(await storage.readRefreshToken(), isNull);
      },
    );

    test(
      'invalid credentials returns to unauthenticated with the mapped message',
      () async {
        final api = FakeAuthApi()
          ..queueLoginError(TestApiErrors.invalidCredentials());
        final controller = _buildController(api: api);

        await controller.login(
          universityEmail: 'student@rsu.ac.th',
          password: 'wrong',
          keepSignedIn: false,
        );

        expect(controller.status, AuthStatus.unauthenticated);
        expect(controller.errorMessage, AuthMessages.invalidCredentials);
        expect(controller.user, isNull);
      },
    );

    test(
      'timeout surfaces the timeout message without clearing anything',
      () async {
        final api = FakeAuthApi()..queueLoginError(TestApiErrors.timeout());
        final controller = _buildController(api: api);

        await controller.login(
          universityEmail: 'student@rsu.ac.th',
          password: 'secret',
          keepSignedIn: false,
        );

        expect(controller.status, AuthStatus.unauthenticated);
        expect(controller.errorMessage, AuthMessages.timeout);
      },
    );

    test('malformed response leaves the user unauthenticated', () async {
      final api = FakeAuthApi()
        ..queueLoginError(const MalformedResponseException());
      final controller = _buildController(api: api);

      await controller.login(
        universityEmail: 'student@rsu.ac.th',
        password: 'secret',
        keepSignedIn: false,
      );

      expect(controller.status, AuthStatus.unauthenticated);
      expect(controller.errorMessage, isNotNull);
    });

    test(
      'duplicate submissions while a login is in flight are ignored',
      () async {
        final api = FakeAuthApi();
        // Queue a never-completing future for the first attempt.
        final gate = Completer<void>();
        api.queueLoginFuture(gate.future.then((_) => buildSession()));
        final controller = _buildController(api: api);

        final first = controller.login(
          universityEmail: 'student@rsu.ac.th',
          password: 'secret',
          keepSignedIn: false,
        );
        // Second call during submission must be a no-op (no second API hit).
        await controller.login(
          universityEmail: 'other@rsu.ac.th',
          password: 'secret',
          keepSignedIn: false,
        );
        expect(api.loginCalls, hasLength(1));
        expect(controller.status, AuthStatus.submitting);

        gate.complete();
        await first;
        expect(controller.status, AuthStatus.authenticated);
      },
    );

    test(
      'secure-storage write failure still authenticates in memory',
      () async {
        final api = FakeAuthApi()..queueLoginSuccess(buildSession());
        final storage = _FailingSessionStorage();
        final tokens = TokenStore();
        final controller = _buildController(
          api: api,
          storage: storage,
          tokens: tokens,
        );

        await controller.login(
          universityEmail: 'student@rsu.ac.th',
          password: 'secret',
          keepSignedIn: true,
        );

        expect(controller.status, AuthStatus.authenticated);
        expect(tokens.accessToken, isNotNull);
        expect(storage.writes, greaterThan(0));
      },
    );
  });

  group('AuthController.logout', () {
    test('clears tokens, persisted session and tells the backend', () async {
      final api = FakeAuthApi()
        ..queueLoginSuccess(buildSession())
        ..queueLogoutSuccess();
      final storage = InMemorySessionStorage();
      final tokens = TokenStore();
      final controller = _buildController(
        api: api,
        storage: storage,
        tokens: tokens,
      );
      await controller.login(
        universityEmail: 'student@rsu.ac.th',
        password: 'secret',
        keepSignedIn: true,
      );
      expect(controller.status, AuthStatus.authenticated);

      await controller.logout();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(controller.user, isNull);
      expect(tokens.accessToken, isNull);
      expect(tokens.refreshToken, isNull);
      expect(await storage.readRefreshToken(), isNull);
      expect(api.logoutCalls, hasLength(1));
    });

    test('a backend logout failure still clears local state', () async {
      final api = FakeAuthApi()
        ..queueLoginSuccess(buildSession())
        ..queueLogoutError(TestApiErrors.noConnection());
      final storage = InMemorySessionStorage();
      final tokens = TokenStore();
      final controller = _buildController(
        api: api,
        storage: storage,
        tokens: tokens,
      );
      await controller.login(
        universityEmail: 'student@rsu.ac.th',
        password: 'secret',
        keepSignedIn: true,
      );

      await controller.logout();

      expect(controller.status, AuthStatus.unauthenticated);
      expect(tokens.accessToken, isNull);
      expect(await storage.readRefreshToken(), isNull);
    });

    test(
      'a late login response after logout must not restore the old session',
      () async {
        final api = FakeAuthApi();
        final gate = Completer<void>();
        api.queueLoginFuture(gate.future.then((_) => buildSession()));
        final controller = _buildController(api: api);

        final pending = controller.login(
          universityEmail: 'student@rsu.ac.th',
          password: 'secret',
          keepSignedIn: false,
        );
        expect(controller.status, AuthStatus.submitting);

        // Log out before the login response comes back.
        await controller.logout();
        expect(controller.status, AuthStatus.unauthenticated);

        gate.complete();
        await pending;

        // Even though the server now says we are authenticated, logout
        // bumped the sequence so the controller must drop the response.
        expect(controller.status, AuthStatus.unauthenticated);
      },
    );
  });
}
