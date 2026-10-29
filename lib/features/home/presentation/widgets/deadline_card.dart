import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../demo/home_demo_data.dart';
import 'home_icons.dart';
import 'home_surface.dart';

/// "Upcoming Deadlines" section (Figma node `3:468`).
class UpcomingDeadlinesSection extends StatelessWidget {
  const UpcomingDeadlinesSection({
    super.key,
    required this.badge,
    required this.deadlines,
    required this.onDeadlineTap,
  });

  final String badge;
  final List<HomeDeadline> deadlines;
  final ValueChanged<HomeDeadline> onDeadlineTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeading(
          title: 'Upcoming Deadlines',
          trailing: HomeBadge(
            label: badge,
            background: AppColors.urgent,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            textStyle: AppFonts.interStyle(
              size: 9,
              weight: FontWeight.w700,
              height: 1.5,
              color: Colors.white,
            ),
          ),
        ),
        for (final deadline in deadlines) ...[
          const SizedBox(height: 10),
          DeadlineCard(
            deadline: deadline,
            onTap: () => onDeadlineTap(deadline),
          ),
        ],
      ],
    );
  }
}

/// Colours for one [DeadlineTone].
class _ToneColors {
  const _ToneColors({
    required this.strip,
    required this.tint,
    required this.text,
  });

  final Color strip;
  final Color tint;
  final Color text;

  static _ToneColors of(DeadlineTone tone) => switch (tone) {
    DeadlineTone.urgent => const _ToneColors(
      strip: AppColors.urgent,
      tint: AppColors.urgentLight,
      text: AppColors.urgent,
    ),
    DeadlineTone.warning => const _ToneColors(
      strip: AppColors.amber,
      tint: AppColors.amberLight,
      text: AppColors.amberText,
    ),
    DeadlineTone.neutral => const _ToneColors(
      strip: AppColors.textSecondary,
      tint: AppColors.divider,
      text: AppColors.textSecondary,
    ),
  };
}

/// One deadline row: coloured strip, icon, course/category, title, due label.
class DeadlineCard extends StatelessWidget {
  const DeadlineCard({super.key, required this.deadline, required this.onTap});

  final HomeDeadline deadline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _ToneColors.of(deadline.tone);

    return HomeSurface(
      radius: 14,
      shadows: AppShadows.card,
      onTap: onTap,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: ColoredBox(color: colors.strip),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.tint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: HomeIcon(deadline.icon, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              deadline.code,
                              style: AppFonts.interStyle(
                                size: 10,
                                weight: FontWeight.w900,
                                height: 1.5,
                                color: colors.text,
                              ),
                            ),
                            HomeBadge(
                              label: deadline.category,
                              background: colors.tint,
                              textStyle: AppFonts.interStyle(
                                size: 9,
                                weight: FontWeight.w600,
                                height: 1.5,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          deadline.title,
                          style: AppFonts.interStyle(
                            size: 12,
                            weight: FontWeight.w600,
                            height: 16.5 / 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      deadline.dueLabel,
                      textAlign: TextAlign.end,
                      style: AppFonts.interStyle(
                        size: 10,
                        weight: FontWeight.w700,
                        height: 1.5,
                        color: colors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
