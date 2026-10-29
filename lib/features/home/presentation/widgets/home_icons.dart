import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG icons exported from the Figma home frame (3:209).
///
/// Colours are baked into each file as in the design, so they are drawn
/// without tinting.
abstract final class HomeIcons {
  static const String _dir = 'assets/icons/home';

  static const String headerDecoration = '$_dir/header_decoration.svg';
  static const String bell = '$_dir/bell.svg';

  static const String chipBuilding = '$_dir/chip_building.svg';
  static const String chipRoom = '$_dir/chip_room.svg';
  static const String chipTime = '$_dir/chip_time.svg';
  static const String calendar = '$_dir/calendar.svg';
  static const String navigate = '$_dir/navigate.svg';

  static const String aiRobot = '$_dir/ai_robot.svg';
  static const String suggestCalendar = '$_dir/suggest_calendar.svg';
  static const String suggestAssignment = '$_dir/suggest_assignment.svg';
  static const String suggestLocation = '$_dir/suggest_location.svg';
  static const String askAiChat = '$_dir/ask_ai_chat.svg';

  static const String qaTimetable = '$_dir/qa_timetable.svg';
  static const String qaCampusMap = '$_dir/qa_campus_map.svg';
  static const String qaAssignments = '$_dir/qa_assignments.svg';
  static const String qaExams = '$_dir/qa_exams.svg';
  static const String qaStudyAssist = '$_dir/qa_study_assist.svg';
  static const String qaMyCourses = '$_dir/qa_my_courses.svg';
  static const String qaUniversity = '$_dir/qa_university.svg';

  static const String deadlineAssignmentRed =
      '$_dir/deadline_assignment_red.svg';
  static const String deadlineExamAmber = '$_dir/deadline_exam_amber.svg';
  static const String deadlineAssignmentGray =
      '$_dir/deadline_assignment_gray.svg';

  static const String chevronRight = '$_dir/chevron_right.svg';
}

/// Square SVG icon drawn at its Figma size.
class HomeIcon extends StatelessWidget {
  const HomeIcon(this.asset, {super.key, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}
