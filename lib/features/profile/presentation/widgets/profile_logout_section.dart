import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_icons.dart';
import 'profile_icons.dart';

/// Full-width pale-red Logout button with the version footer centred below
/// it (Figma node `28:298`).
class ProfileLogoutSection extends StatelessWidget {
  const ProfileLogoutSection({
    super.key,
    required this.versionLabel,
    required this.onLogout,
  });

  final String versionLabel;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: onLogout,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.urgentLight,
            foregroundColor: AppColors.urgent,
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            side: const BorderSide(color: AppColors.logoutBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: AppFonts.interStyle(size: 14, height: 1.5),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HomeIcon(ProfileIcons.logout, size: 16),
              SizedBox(width: 8),
              Flexible(child: Text('Logout', textAlign: TextAlign.center)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          versionLabel,
          textAlign: TextAlign.center,
          style: AppFonts.interStyle(
            size: 10,
            weight: FontWeight.w500,
            height: 1.5,
            color: AppColors.textFaint,
          ),
        ),
      ],
    );
  }
}
