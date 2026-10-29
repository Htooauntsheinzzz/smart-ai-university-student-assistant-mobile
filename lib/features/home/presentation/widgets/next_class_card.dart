import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../demo/home_demo_data.dart';
import 'home_icons.dart';
import 'home_surface.dart';

/// "Next Class" card (Figma node `3:260`).
class NextClassCard extends StatelessWidget {
  const NextClassCard({
    super.key,
    required this.nextClass,
    required this.onViewClass,
    required this.onNavigate,
  });

  final HomeNextClass nextClass;
  final VoidCallback onViewClass;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return HomeSurface(
      shadows: AppShadows.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(countdown: nextClass.countdown),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _CourseInfo(nextClass: nextClass)),
                    const SizedBox(width: 12),
                    _TimePanel(
                      start: nextClass.startTime,
                      end: nextClass.endTime,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: HomeIcons.chipBuilding,
                      label: nextClass.building,
                    ),
                    _InfoChip(icon: HomeIcons.chipRoom, label: nextClass.room),
                    _InfoChip(
                      icon: HomeIcons.chipTime,
                      label: '${nextClass.startTime} – ${nextClass.endTime}',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ClassButton(
                        label: 'View Class',
                        icon: HomeIcons.calendar,
                        filled: false,
                        onTap: onViewClass,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ClassButton(
                        label: 'Navigate',
                        icon: HomeIcons.navigate,
                        filled: true,
                        onTap: onNavigate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.countdown});

  final String countdown;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppFonts.interStyle(
      size: 10,
      weight: FontWeight.w700,
      height: 1.5,
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const _StatusDot(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'NEXT CLASS',
              style: labelStyle.copyWith(
                letterSpacing: 1,
                color: const Color(0xCCFFFFFF),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: HomeBadge(
              label: countdown,
              background: const Color(0x33FFFFFF),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              textStyle: labelStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// 6 dp green "live" dot.
class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.91),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CourseInfo extends StatelessWidget {
  const _CourseInfo({required this.nextClass});

  final HomeNextClass nextClass;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              nextClass.code,
              style: AppFonts.interStyle(
                size: 12,
                weight: FontWeight.w900,
                height: 1.5,
                letterSpacing: 0.3,
                color: AppColors.accentBlue,
              ),
            ),
            HomeBadge(
              label: nextClass.category,
              background: AppColors.accentBlueLight,
              borderColor: AppColors.accentBlue.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              textStyle: AppFonts.interStyle(
                size: 9,
                weight: FontWeight.w600,
                height: 1.5,
                color: AppColors.accentBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          nextClass.title,
          style: AppFonts.poppinsBold(
            size: 15,
            height: 20.625 / 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _TimePanel extends StatelessWidget {
  const _TimePanel({required this.start, required this.end});

  final String start;
  final String end;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 52, minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.timePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            start,
            style: AppFonts.interStyle(
              size: 10,
              weight: FontWeight.w900,
              height: 1,
              color: AppColors.accentBlue,
            ),
          ),
          Container(
            width: 16,
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 2),
            color: AppColors.accentBlue.withValues(alpha: 0.3),
          ),
          Text(
            end,
            style: AppFonts.interStyle(
              size: 8,
              weight: FontWeight.w600,
              height: 1,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HomeIcon(icon, size: 12),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppFonts.interStyle(
                size: 10,
                weight: FontWeight.w600,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassButton extends StatelessWidget {
  const _ClassButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeSurface(
      color: filled ? AppColors.background : Colors.white,
      borderColor: filled ? null : AppColors.background,
      borderWidth: 2,
      shadows: filled ? AppShadows.darkButton : const [],
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HomeIcon(icon, size: 13),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppFonts.interStyle(
                    size: 12,
                    height: 1.5,
                    color: filled ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
