import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Centred copyright lines below the login card.
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '© 2026 Rangsit University\n'
      'Smart AI University Student Assistant\n'
      'All rights reserved.',
      textAlign: TextAlign.center,
      style: AppFonts.interStyle(
        size: 10,
        weight: FontWeight.w500,
        color: AppColors.footer,
        height: 16.25 / 10,
      ),
    );
  }
}
