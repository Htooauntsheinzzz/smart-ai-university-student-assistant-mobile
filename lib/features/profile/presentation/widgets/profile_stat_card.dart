import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../demo/profile_demo_data.dart';

/// Compact statistic on the dark header (Figma node `28:73`): the value over
/// an upper-case label on a translucent white card.
class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({super.key, required this.stat});

  final ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stat.value,
              textAlign: TextAlign.center,
              style: AppFonts.interStyle(
                size: 20,
                weight: FontWeight.w900,
                height: 1.5,
                color: Colors.white,
              ),
            ),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              style: AppFonts.interStyle(
                size: 9,
                weight: FontWeight.w600,
                height: 1.5,
                color: const Color(0x99FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
