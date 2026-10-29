/// Volatile holder for the access and refresh tokens that are active in
/// this app process (DEC-010).
///
/// The access token is short-lived (15 minutes by backend configuration)
/// and never written to disk; the refresh token lives here while the
/// user is signed in and is separately persisted by [SessionStorage]
/// when Keep Me Signed In is selected.
class TokenStore {
  TokenStore();

  String? _accessToken;
  String? _refreshToken;

  /// Current bearer access token, or `null` when no session is active.
  String? get accessToken => _accessToken;

  set accessToken(String? value) {
    if (value == null || value.isEmpty) {
      _accessToken = null;
    } else {
      _accessToken = value;
    }
  }

  /// Current refresh token in memory, or `null` when no session is
  /// active. Does **not** read persisted storage; use [SessionStorage]
  /// for that.
  String? get refreshToken => _refreshToken;

  set refreshToken(String? value) {
    if (value == null || value.isEmpty) {
      _refreshToken = null;
    } else {
      _refreshToken = value;
    }
  }

  /// Drops both tokens from memory.
  void clear() {
    _accessToken = null;
    _refreshToken = null;
  }
}
