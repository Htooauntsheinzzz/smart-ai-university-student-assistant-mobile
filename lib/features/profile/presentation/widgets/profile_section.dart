import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Upper-case section heading (Inter Bold 10, Figma node `28:100`) with its
/// card 12 below.
class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key, required this.title, required this.child});

  /// Heading text, already upper case as in the design.
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: AppFonts.interStyle(
              size: 10,
              weight: FontWeight.w700,
              height: 1.5,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
