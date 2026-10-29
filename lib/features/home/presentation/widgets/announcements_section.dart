import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../demo/home_demo_data.dart';
import 'home_icons.dart';
import 'home_surface.dart';

/// "Announcements" section (Figma node `3:544`).
class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({
    super.key,
    required this.announcements,
    required this.onSeeAll,
    required this.onAnnouncementTap,
  });

  final List<HomeAnnouncement> announcements;
  final VoidCallback onSeeAll;
  final ValueChanged<HomeAnnouncement> onAnnouncementTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeading(
          title: 'Announcements',
          trailing: TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentBlue,
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              textStyle: AppFonts.interStyle(size: 12, height: 1.5),
            ),
            child: const Text('See all'),
          ),
        ),
        const SizedBox(height: 10),
        HomeSurface(
          radius: 14,
          shadows: AppShadows.card,
          child: Column(
            children: [
              for (final (index, announcement) in announcements.indexed) ...[
                if (index > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                _AnnouncementRow(
                  announcement: announcement,
                  onTap: () => onAnnouncementTap(announcement),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AnnouncementRow extends StatelessWidget {
  const _AnnouncementRow({required this.announcement, required this.onTap});

  final HomeAnnouncement announcement;
  final VoidCallback onTap;

  static Color _categoryColor(AnnouncementCategory category) =>
      switch (category) {
        AnnouncementCategory.academic => AppColors.accentBlue,
        AnnouncementCategory.campus => AppColors.success,
        AnnouncementCategory.events => AppColors.brandDot,
      };

  static String _categoryLabel(AnnouncementCategory category) =>
      switch (category) {
        AnnouncementCategory.academic => 'Academic',
        AnnouncementCategory.campus => 'Campus',
        AnnouncementCategory.events => 'Events',
      };

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(announcement.category);
    final unread = announcement.unread;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _Dot(color: unread ? categoryColor : AppColors.inactiveDot),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    announcement.title,
                    style: AppFonts.interStyle(
                      size: 12,
                      weight: unread ? FontWeight.w600 : FontWeight.w400,
                      height: 16.5 / 12,
                      color: unread
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      HomeBadge(
                        label: _categoryLabel(announcement.category),
                        background: categoryColor.withValues(alpha: 0.09),
                        radius: 4,
                        textStyle: AppFonts.interStyle(
                          size: 9,
                          weight: FontWeight.w700,
                          height: 1.5,
                          color: categoryColor,
                        ),
                      ),
                      Text(
                        announcement.timeLabel,
                        style: AppFonts.interStyle(
                          size: 9,
                          height: 1.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: 12),
              const _Dot(color: AppColors.accentBlue),
            ],
            const SizedBox(width: 12),
            const HomeIcon(HomeIcons.chevronRight, size: 12),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
