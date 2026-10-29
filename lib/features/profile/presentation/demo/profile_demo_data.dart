import 'package:flutter/painting.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../auth/data/models/student_user.dart';
import '../widgets/profile_icons.dart';

// DEMO DATA — static fixture content copied from the Figma frame
// `Profile Screen` (28:30). The identity bits (name, initial, student
// code, university email) now come from the authenticated backend
// student (DEC-010); the academic rows (Major, Academic Year, Faculty,
// Department, Program, Semester) remain fixture here until a dedicated
// academic spec replaces them, and the stats (CGPA, credits, courses)
// are not returned by the current API.

class ProfileStudent {
  const ProfileStudent({
    required this.name,
    required this.initial,
    required this.studentId,
  });

  final String name;
  final String initial;
  final String studentId;
}

/// One compact statistic card on the header.
class ProfileStat {
  const ProfileStat({required this.value, required this.label});

  final String value;
  final String label;
}

/// One display-only row of the Student Information card.
class ProfileInfoRow {
  const ProfileInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final String icon;
}

/// What a profile action should do once its feature exists; today every
/// action shows a placeholder message.
enum ProfileAction {
  editProfile,
  settings,
  myCourses,
  personalInformation,
  notificationPreferences,
  changePassword,
  help,
  about,
}

/// One row of a grouped menu card.
class ProfileMenuItem {
  const ProfileMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.action,
  });

  final String title;
  final String subtitle;
  final String icon;

  /// Colour behind the icon, drawn at 9 % opacity.
  final Color accent;
  final ProfileAction action;
}

abstract final class ProfileDemoData {
  /// Build the header model from the authenticated student (DEC-010).
  static ProfileStudent studentFor(StudentUser user) {
    final name = user.firstName.trim().isNotEmpty
        ? user.firstName.trim()
        : user.fullName;
    return ProfileStudent(
      name: name,
      initial: user.initial,
      studentId: user.studentCode,
    );
  }

  /// Build the Student Information rows. The Email row is driven by
  /// the authenticated student; the academic rows stay fixture until a
  /// dedicated spec integrates them.
  static List<ProfileInfoRow> informationFor(StudentUser user) {
    return [
      ..._academicInformation,
      ProfileInfoRow(
        label: 'Email',
        value: user.universityEmail,
        icon: ProfileIcons.infoEmail,
      ),
    ];
  }

  /// Values reproduce the design as-is; nothing is calculated.
  static const stats = [
    ProfileStat(value: '3.42', label: 'CGPA'),
    ProfileStat(value: '87', label: 'CREDITS'),
    ProfileStat(value: '5', label: 'COURSES'),
  ];

  /// Academic information rows that are still fixture; the Email row
  /// is added at runtime from the authenticated student (DEC-010).
  static const List<ProfileInfoRow> _academicInformation = [
    ProfileInfoRow(
      label: 'Major',
      value: 'Computer Science',
      icon: ProfileIcons.infoMajor,
    ),
    ProfileInfoRow(
      label: 'Academic Year',
      value: 'Year 3',
      icon: ProfileIcons.infoCalendar,
    ),
    ProfileInfoRow(
      label: 'Faculty',
      value: 'Faculty of Information Technology',
      icon: ProfileIcons.infoFaculty,
    ),
    ProfileInfoRow(
      label: 'Department',
      value: 'Computer Science',
      icon: ProfileIcons.infoDepartment,
    ),
    ProfileInfoRow(
      label: 'Program',
      value: 'Bachelor of Science',
      icon: ProfileIcons.infoProgram,
    ),
    ProfileInfoRow(
      label: 'Semester',
      value: 'Semester 1 / 2026',
      icon: ProfileIcons.infoCalendar,
    ),
  ];

  static const academicMenu = [
    ProfileMenuItem(
      title: 'My Courses',
      subtitle: '5 enrolled this semester',
      icon: ProfileIcons.menuCourses,
      accent: AppColors.accentBlue,
      action: ProfileAction.myCourses,
    ),
  ];

  static const accountMenu = [
    ProfileMenuItem(
      title: 'Personal Information',
      subtitle: 'Edit your profile details',
      icon: ProfileIcons.menuPersonalInfo,
      accent: AppColors.accentPurple,
      action: ProfileAction.personalInformation,
    ),
    ProfileMenuItem(
      title: 'Notification Preferences',
      subtitle: 'Manage alerts & reminders',
      icon: ProfileIcons.menuNotifications,
      accent: AppColors.brandDot,
      action: ProfileAction.notificationPreferences,
    ),
    ProfileMenuItem(
      title: 'Change Password',
      subtitle: 'Update your password',
      icon: ProfileIcons.menuPassword,
      accent: AppColors.amber,
      action: ProfileAction.changePassword,
    ),
  ];

  static const appMenu = [
    ProfileMenuItem(
      title: 'Settings',
      subtitle: 'App preferences',
      icon: ProfileIcons.menuSettings,
      accent: AppColors.textSecondary,
      action: ProfileAction.settings,
    ),
    ProfileMenuItem(
      title: 'Help',
      subtitle: 'Get support',
      icon: ProfileIcons.menuHelp,
      accent: AppColors.success,
      action: ProfileAction.help,
    ),
    ProfileMenuItem(
      title: 'About',
      subtitle: appVersionLabel,
      icon: ProfileIcons.menuAbout,
      accent: AppColors.textPrimary,
      action: ProfileAction.about,
    ),
  ];

  /// Preview text from the frame; not the real build version.
  static const String appVersionLabel = 'SMART AI v2.0.1';
  static const String footerVersionLabel =
      'SMART AI University Assistant v2.0.1';
}
