import 'package:flutter/material.dart';

import '../../../auth/data/models/student_user.dart';
import '../demo/profile_demo_data.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_logout_section.dart';
import '../widgets/profile_menu_group.dart';
import '../widgets/profile_section.dart';
import '../widgets/student_information_card.dart';

/// Profile screen from the Figma frame `Profile Screen` (node `28:30`).
///
/// Shown as a tab of the signed-in app shell, which supplies the Scaffold and
/// the shared bottom navigation. Identity bits (name, student code, email)
/// come from the authenticated backend student (DEC-010); the remaining rows
/// are still fixture, kept until a later spec integrates the academic APIs.
/// Every action except Logout belongs to a feature that does not exist yet,
/// so taps show a short "not implemented yet" message. Logout calls the
/// supplied [onLogout] callback, which clears both the server-side session
/// and the local credentials (DEC-010).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.student,
    required this.onLogout,
  });

  /// Signed-in student used for the header and Student Information rows.
  final StudentUser student;

  /// Called when the Logout button is confirmed. The shell is removed
  /// from the tree once the controller flips to unauthenticated, so
  /// this screen will not continue to run.
  final Future<void> Function() onLogout;

  /// Widest the content grows on tablets (Figma content is 370 wide).
  static const double _maxContentWidth = 600;

  /// Placeholder message shown for [action] until its feature exists.
  static String messageFor(ProfileAction action) => switch (action) {
    ProfileAction.editProfile || ProfileAction.personalInformation =>
      'Profile editing is not implemented yet.',
    ProfileAction.notificationPreferences =>
      'Notification preferences are not implemented yet.',
    ProfileAction.changePassword => 'Password changes are not implemented yet.',
    ProfileAction.myCourses => 'My Courses is not implemented yet.',
    ProfileAction.settings => 'Settings is not implemented yet.',
    ProfileAction.help => 'Help is not implemented yet.',
    ProfileAction.about => 'About is not implemented yet.',
  };

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Set once logout started, so a second tap during the transition
  /// cannot fire the callback twice.
  bool _loggingOut = false;

  void _onAction(ProfileAction action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(ProfileScreen.messageFor(action))));
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    // Latch to true for the lifetime of this widget: once a logout
    // starts the controller flips to unauthenticated and the shell is
    // removed from the tree, so there is no supported path back from
    // this state within the same ProfileScreen instance.
    setState(() => _loggingOut = true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    await widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(
            student: ProfileDemoData.studentFor(widget.student),
            stats: ProfileDemoData.stats,
            onSettingsTap: () => _onAction(ProfileAction.settings),
            onEditProfileTap: () => _onAction(ProfileAction.editProfile),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ProfileScreen._maxContentWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: _ProfileContent(
                    student: widget.student,
                    onAction: _onAction,
                    onLogout: _logout,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.student,
    required this.onAction,
    required this.onLogout,
  });

  final StudentUser student;
  final ValueChanged<ProfileAction> onAction;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 20);
    void onItemTap(ProfileMenuItem item) => onAction(item.action);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gap,
        ProfileSection(
          title: 'STUDENT INFORMATION',
          child: StudentInformationCard(
            rows: ProfileDemoData.informationFor(student),
          ),
        ),
        gap,
        ProfileSection(
          title: 'ACADEMIC',
          child: ProfileMenuGroup(
            items: ProfileDemoData.academicMenu,
            onItemTap: onItemTap,
          ),
        ),
        gap,
        ProfileSection(
          title: 'ACCOUNT',
          child: ProfileMenuGroup(
            items: ProfileDemoData.accountMenu,
            onItemTap: onItemTap,
          ),
        ),
        gap,
        ProfileSection(
          title: 'APP',
          child: ProfileMenuGroup(
            items: ProfileDemoData.appMenu,
            onItemTap: onItemTap,
          ),
        ),
        gap,
        ProfileLogoutSection(
          versionLabel: ProfileDemoData.footerVersionLabel,
          onLogout: onLogout,
        ),
      ],
    );
  }
}
