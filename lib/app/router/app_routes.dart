/// Named routes used by the app's [MaterialApp].
///
/// Plain named routes are used until `go_router` and auth redirects are
/// introduced with the authentication feature (DEC-005). [home], [aiChat] and
/// [profile] open the signed-in app shell on that tab (DEC-008, DEC-009).
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String aiChat = '/ai-chat';
  static const String profile = '/profile';
}
