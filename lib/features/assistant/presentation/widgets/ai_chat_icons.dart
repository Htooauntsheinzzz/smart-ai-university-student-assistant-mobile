/// SVG icons and artwork exported from the Figma frame `Ai-Chat Screen`
/// (33:30), drawn with the shared `HomeIcon` at their Figma sizes.
///
/// Colours are baked into each file as in the design; only the Send arrow is
/// tinted white for the enabled state, which the frame does not show.
abstract final class AiChatIcons {
  static const String _dir = 'assets/icons/ai_chat';

  static const String headerDecoration = '$_dir/header_decoration.svg';
  static const String headerRobot = '$_dir/header_robot.svg';
  static const String history = '$_dir/history.svg';
  static const String plus = '$_dir/plus.svg';

  static const String promptCalendar = '$_dir/prompt_calendar.svg';
  static const String promptLocation = '$_dir/prompt_location.svg';
  static const String promptAssignment = '$_dir/prompt_assignment.svg';
  static const String promptExam = '$_dir/prompt_exam.svg';
  static const String promptNavigate = '$_dir/prompt_navigate.svg';

  static const String avatarRobot = '$_dir/avatar_robot.svg';
  static const String attach = '$_dir/attach.svg';
  static const String send = '$_dir/send.svg';
}
