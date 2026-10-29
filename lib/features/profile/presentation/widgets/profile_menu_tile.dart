import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_icons.dart';
import '../demo/profile_demo_data.dart';
import 'profile_icons.dart';

/// One tappable menu row (Figma node `28:197`): tinted icon container, title
/// over subtitle, and a trailing chevron. Must sit inside a [Material] (the
/// group card) for its ink.
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({super.key, required this.item, required this.onTap});

  final ProfileMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.accent.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: HomeIcon(item.icon, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: AppFonts.interStyle(
                            size: 13,
                            weight: FontWeight.w700,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          item.subtitle,
                          style: AppFonts.interStyle(
                            size: 11,
                            height: 1.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const HomeIcon(ProfileIcons.chevronRight, size: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
