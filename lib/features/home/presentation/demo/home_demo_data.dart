import 'package:flutter/painting.dart';

import '../../../auth/data/models/student_user.dart';
import '../widgets/home_icons.dart';

// DEMO DATA — static fixture content copied from the Figma frame
// `Home Page Screen` (3:209). The identity bits of the header (name,
// initial, programme and academic year) now come from the authenticated
// backend student (DEC-010); the rest is still fixture and will be
// replaced when the academic endpoints are integrated (DEC-006).

/// Colour treatment of a deadline row.
enum DeadlineTone { urgent, warning, neutral }

/// Category of an announcement, which sets its badge and dot colour.
enum AnnouncementCategory { academic, campus, events }

class HomeStudent {
  const HomeStudent({
    required this.greeting,
    required this.name,
    required this.details,
    required this.initial,
    required this.notificationCount,
    required this.dateLabel,
  });

  final String greeting;
  final String name;
  final String details;
  final String initial;
  final int notificationCount;

  /// Fixed reference date from the design, not today's date.
  final String dateLabel;
}

class HomeNextClass {
  const HomeNextClass({
    required this.countdown,
    required this.code,
    required this.category,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.building,
    required this.room,
  });

  final String countdown;
  final String code;
  final String category;
  final String title;
  final String startTime;
  final String endTime;
  final String building;
  final String room;
}

class HomeSuggestion {
  const HomeSuggestion({required this.label, required this.icon});

  final String label;
  final String icon;
}

class HomeQuickAction {
  const HomeQuickAction({
    required this.label,
    required this.icon,
    required this.iconBackground,
  });

  final String label;
  final String icon;
  final Color iconBackground;
}

class HomeDeadline {
  const HomeDeadline({
    required this.code,
    required this.category,
    required this.title,
    required this.dueLabel,
    required this.tone,
    required this.icon,
  });

  final String code;
  final String category;
  final String title;
  final String dueLabel;
  final DeadlineTone tone;
  final String icon;
}

class HomeAnnouncement {
  const HomeAnnouncement({
    required this.title,
    required this.category,
    required this.timeLabel,
    required this.unread,
  });

  final String title;
  final AnnouncementCategory category;
  final String timeLabel;
  final bool unread;
}

abstract final class HomeDemoData {
  /// Build the header model from the signed-in student. The identity
  /// fields come from the backend; everything else is still fixture
  /// until a dedicated academic feature replaces it.
  static HomeStudent studentFor(
    StudentUser user, {
    DateTime? now,
    int notificationCount = 0,
  }) {
    final clock = now ?? DateTime.now();
    final displayName = user.firstName.trim().isNotEmpty
        ? user.firstName.trim()
        : user.fullName;
    final program = user.programName?.trim() ?? '';
    final year = user.academicYear;
    final details = switch ((program.isNotEmpty, year != null)) {
      (true, true) => '$program · Year $year',
      (true, false) => program,
      (false, true) => 'Year $year',
      _ => '',
    };
    return HomeStudent(
      greeting: _greetingFor(clock),
      name: displayName,
      details: details,
      initial: user.initial,
      notificationCount: notificationCount,
      dateLabel: _dateLabel(clock),
    );
  }

  static String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 5) return 'Good Evening';
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static const List<String> _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String _dateLabel(DateTime now) {
    final weekday = _weekdayNames[now.weekday - 1];
    final month = _monthNames[now.month - 1];
    return '$weekday, $month ${now.day}, ${now.year}';
  }

  static const nextClass = HomeNextClass(
    countdown: 'Starts in 45 min',
    code: 'CSC-452',
    category: 'Lecture',
    title: 'Mobile Programming',
    startTime: '09:00',
    endTime: '11:45',
    building: 'Building 11',
    room: 'Room 1103',
  );

  static const suggestions = [
    HomeSuggestion(
      label: "What's my next class?",
      icon: HomeIcons.suggestCalendar,
    ),
    HomeSuggestion(
      label: 'Any assignments due?',
      icon: HomeIcons.suggestAssignment,
    ),
    HomeSuggestion(
      label: 'Take me to next class',
      icon: HomeIcons.suggestLocation,
    ),
  ];

  static const quickActions = [
    HomeQuickAction(
      label: 'Timetable',
      icon: HomeIcons.qaTimetable,
      iconBackground: Color(0xFFE8F5FC),
    ),
    HomeQuickAction(
      label: 'Campus Map',
      icon: HomeIcons.qaCampusMap,
      iconBackground: Color(0xFFFCE8EF),
    ),
    HomeQuickAction(
      label: 'Assignments',
      icon: HomeIcons.qaAssignments,
      iconBackground: Color(0xFFEDE9FE),
    ),
    HomeQuickAction(
      label: 'Exams',
      icon: HomeIcons.qaExams,
      iconBackground: Color(0xFFFEF3C7),
    ),
    HomeQuickAction(
      label: 'Study Assist',
      icon: HomeIcons.qaStudyAssist,
      iconBackground: Color(0xFFDCFCE7),
    ),
    HomeQuickAction(
      label: 'My Courses',
      icon: HomeIcons.qaMyCourses,
      iconBackground: Color(0xFFE8EDF5),
    ),
    HomeQuickAction(
      label: 'University',
      icon: HomeIcons.qaUniversity,
      iconBackground: Color(0xFFEEF2FF),
    ),
  ];

  /// Labels reproduce the design as-is; they are not recalculated.
  static const deadlinesBadge = '1 due today';

  static const deadlines = [
    HomeDeadline(
      code: 'CSC-452',
      category: 'Assignment',
      title: 'Mobile UI Prototype',
      dueLabel: 'Today, 23:59',
      tone: DeadlineTone.urgent,
      icon: HomeIcons.deadlineAssignmentRed,
    ),
    HomeDeadline(
      code: 'CSC-401',
      category: 'Midterm Exam',
      title: 'Data Structures Midterm',
      dueLabel: 'Thu, Oct 17',
      tone: DeadlineTone.warning,
      icon: HomeIcons.deadlineExamAmber,
    ),
    HomeDeadline(
      code: 'CSC-311',
      category: 'Assignment',
      title: 'Network Lab Report',
      dueLabel: 'Fri, Oct 18',
      tone: DeadlineTone.neutral,
      icon: HomeIcons.deadlineAssignmentGray,
    ),
  ];

  static const announcements = [
    HomeAnnouncement(
      title: 'Mid-term Exam Schedule Released',
      category: AnnouncementCategory.academic,
      timeLabel: '2 hrs ago',
      unread: true,
    ),
    HomeAnnouncement(
      title: 'Library Extended Hours: Oct–Nov 2026',
      category: AnnouncementCategory.campus,
      timeLabel: 'Yesterday',
      unread: true,
    ),
    HomeAnnouncement(
      title: 'RSU Sports Day Registration Now Open',
      category: AnnouncementCategory.events,
      timeLabel: '2 days ago',
      unread: false,
    ),
  ];
}
