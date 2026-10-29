import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../data/auth_api.dart';
import '../../data/models/login_response.dart';
import '../../data/models/student_user.dart';
import '../../data/token_store.dart';

/// Observable login state surfaced to the UI (DEC-010, spec section 9).
enum AuthStatus {
  /// Reading the persisted session and talking to `/refresh` on launch.
  initializing,

  /// Startup failed with a temporary network issue; the user can retry.
  initializationError,

  /// Signed out and ready to accept credentials.
  unauthenticated,

  /// A login request is in flight.
  submitting,

  /// A valid access token is held and the user is on the signed-in area.
  authenticated,
}

/// Orchestrates login, logout, and session restoration between the UI,
/// [AuthApi], [TokenStore], and [SessionStorage]. Notifies listeners
/// every time [status] or any of its fields changes.
class AuthController extends ChangeNotifier {
  AuthController({
    required this.api,
    required this.sessionStorage,
    required this.tokenStore,
  });

  final AuthApi api;
  final SessionStorage sessionStorage;
  final TokenStore tokenStore;

  AuthStatus _status = AuthStatus.initializing;
  StudentUser? _user;
  String? _errorMessage;

  /// Bumped on every explicit login/logout/restore so a late response
  /// from a cancelled operation cannot restore a stale session (spec
  /// section 9: "A late response must not restore a session after
  /// logout or after the operation has been cancelled.").
  int _sequence = 0;

  AuthStatus get status => _status;
  StudentUser? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isSubmitting => _status == AuthStatus.submitting;
  bool get isInitializing => _status == AuthStatus.initializing;
  bool get hasInitializationError => _status == AuthStatus.initializationError;

  /// Read any persisted session and, if present, refresh it. Called
  /// once at app start by the top-level widget.
  Future<void> restore() async {
    final mySeq = ++_sequence;
    _setState(status: AuthStatus.initializing, errorMessage: null);

    String? storedRefresh;
    try {
      storedRefresh = await sessionStorage.readRefreshToken();
    } catch (_) {
      storedRefresh = null;
    }

    if (storedRefresh == null) {
      if (_sequence != mySeq) return;
      _setState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final session = await api.refresh(refreshToken: storedRefresh);
      if (_sequence != mySeq) return;
      await _applySession(session, persist: true);
    } on ApiException catch (e) {
      if (_sequence != mySeq) return;
      // Backend explicitly rejected the stored session; wipe it and
      // return to the login screen with the surfaced reason.
      await _wipeSession();
      _setState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.statusCode == 401
            ? AuthMessages.sessionExpired
            : e.userMessage,
      );
    } on NetworkException catch (e) {
      if (_sequence != mySeq) return;
      // Keep the stored session: a temporary network outage must not
      // destroy credentials the next launch could reuse.
      _setState(
        status: AuthStatus.initializationError,
        errorMessage: e.userMessage,
      );
    } catch (_) {
      if (_sequence != mySeq) return;
      _setState(
        status: AuthStatus.initializationError,
        errorMessage: AuthMessages.generic,
      );
    }
  }

  /// Re-run initialization after an [AuthStatus.initializationError].
  Future<void> retryInitialization() async {
    if (_status != AuthStatus.initializationError) return;
    await restore();
  }

  /// Attempt to sign in with the entered credentials. The call is a
  /// no-op if another login is already in flight.
  Future<void> login({
    required String universityEmail,
    required String password,
    required bool keepSignedIn,
  }) async {
    if (_status == AuthStatus.submitting) return;
    final mySeq = ++_sequence;
    _setState(status: AuthStatus.submitting, errorMessage: null);

    try {
      final session = await api.login(
        universityEmail: universityEmail.trim(),
        password: password,
      );
      if (_sequence != mySeq) return;
      // Clear any session that was persisted before this attempt so the
      // next launch never sees a mixture of the old refresh token and
      // the new user.
      try {
        await sessionStorage.clearRefreshToken();
      } catch (_) {}
      await _applySession(session, persist: keepSignedIn);
    } on ApiException catch (e) {
      if (_sequence != mySeq) return;
      _setState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.userMessage,
      );
    } on NetworkException catch (e) {
      if (_sequence != mySeq) return;
      _setState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.userMessage,
      );
    } on MalformedResponseException catch (e) {
      if (_sequence != mySeq) return;
      _setState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.userMessage,
      );
    } catch (_) {
      if (_sequence != mySeq) return;
      _setState(
        status: AuthStatus.unauthenticated,
        errorMessage: AuthMessages.serverFailure,
      );
    }
  }

  /// Clear the user's email after an error without resetting the whole
  /// screen. Used by the login form when the user starts typing.
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Log out: revoke the session server-side (best effort), clear every
  /// local trace, and move back to the login screen.
  Future<void> logout() async {
    final wasAuthenticated = _status == AuthStatus.authenticated;
    // Bump the sequence first so any late restore / login response
    // cannot restore the just-killed session.
    ++_sequence;
    if (wasAuthenticated) {
      try {
        await api.logout();
      } catch (_) {
        // The spec forbids claiming server-side revocation worked when
        // it did not: just continue with local cleanup.
      }
    }
    await _wipeSession();
    _setState(status: AuthStatus.unauthenticated);
  }

  Future<void> _applySession(
    AuthSession session, {
    required bool persist,
  }) async {
    tokenStore.accessToken = session.accessToken;
    tokenStore.refreshToken = session.refreshToken;
    _user = session.user;
    if (persist) {
      try {
        await sessionStorage.writeRefreshToken(session.refreshToken);
      } catch (_) {
        // Secure storage unavailable (e.g. jailbroken device, locked
        // keychain). The session still works in memory until the app is
        // closed; the user will have to sign in again next launch.
      }
    } else {
      try {
        await sessionStorage.clearRefreshToken();
      } catch (_) {}
    }
    _setState(status: AuthStatus.authenticated);
  }

  Future<void> _wipeSession() async {
    tokenStore.clear();
    _user = null;
    try {
      await sessionStorage.clearRefreshToken();
    } catch (_) {}
  }

  void _setState({required AuthStatus status, String? errorMessage}) {
    _status = status;
    _errorMessage = errorMessage;
    notifyListeners();
  }
}
