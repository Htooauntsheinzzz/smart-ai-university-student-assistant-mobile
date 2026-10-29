/// SVG icons and header artwork exported from the Figma profile frame (28:30).
///
/// Colours are baked into each file as in the design, so they are drawn
/// without tinting (with the shared `HomeIcon` widget). The bottom-navigation
/// icons are the shared ones in `assets/icons/nav/`.
abstract final class ProfileIcons {
  static const String _dir = 'assets/icons/profile';

  static const String headerDecoration = '$_dir/header_decoration.svg';
  static const String settings = '$_dir/settings.svg';
  static const String badgeCheck = '$_dir/badge_check.svg';
  static const String edit = '$_dir/edit.svg';

  static const String infoMajor = '$_dir/info_major.svg';
  static const String infoCalendar = '$_dir/info_calendar.svg';
  static const String infoFaculty = '$_dir/info_faculty.svg';
  static const String infoDepartment = '$_dir/info_department.svg';
  static const String infoProgram = '$_dir/info_program.svg';
  static const String infoEmail = '$_dir/info_email.svg';

  static const String menuCourses = '$_dir/menu_courses.svg';
  static const String menuPersonalInfo = '$_dir/menu_personal_info.svg';
  static const String menuNotifications = '$_dir/menu_notifications.svg';
  static const String menuPassword = '$_dir/menu_password.svg';
  static const String menuSettings = '$_dir/menu_settings.svg';
  static const String menuHelp = '$_dir/menu_help.svg';
  static const String menuAbout = '$_dir/menu_about.svg';

  /// 14 dp chevron; the home frame's chevron is a different 12 dp export.
  static const String chevronRight = '$_dir/chevron_right.svg';
  static const String logout = '$_dir/logout.svg';
}
