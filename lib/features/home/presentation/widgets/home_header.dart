import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_theme.dart';
import '../demo/home_demo_data.dart';
import 'home_icons.dart';

/// Dark greeting header (Figma node `3:215`): avatar, greeting, notification
/// bell and the date row, over the decorative circle artwork.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.student,
    required this.onNotificationsTap,
  });

  final HomeStudent student;
  final VoidCallback onNotificationsTap;

  /// Figma reserves 58 for the status bar, then 14 before the greeting row.
  static const double _statusBarSpace = 58;
  static const double _decorationWidth = 402;
  static const double _decorationHeight = 177.75;

  @override
  Widget build(BuildContext context) {
    // The Figma status-bar space already includes the system inset, so use
    // whichever is larger instead of adding them together.
    final top = math.max(
      _statusBarSpace,
      MediaQuery.viewPaddingOf(context).top,
    );

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset(
              HomeIcons.headerDecoration,
              width: _decorationWidth,
              height: _decorationHeight,
              alignment: Alignment.topRight,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _Avatar(initial: student.initial),
                    const SizedBox(width: 12),
                    Expanded(child: _Greeting(student: student)),
                    const SizedBox(width: 12),
                    _NotificationButton(
                      count: student.notificationCount,
                      onTap: onNotificationsTap,
                    ),
                  ],
                ),
                const SizedBox(height: 22.75),
                _DateRow(label: student.dateLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.avatar,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white30, width: 2),
              boxShadow: AppShadows.raised,
            ),
            child: Text(
              initial,
              textScaler: TextScaler.noScaling,
              style: AppFonts.interStyle(
                size: 18,
                weight: FontWeight.w900,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 36,
            top: 36,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.student});

  final HomeStudent student;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          student.greeting,
          style: AppFonts.interStyle(
            size: 11,
            weight: FontWeight.w500,
            height: 16.5 / 11,
            letterSpacing: 0.275,
            color: Colors.white60,
          ),
        ),
        Text(
          student.name,
          style: AppFonts.poppinsBold(
            size: 19,
            height: 23.75 / 19,
            color: Colors.white,
          ),
        ),
        Text(
          student.details,
          style: AppFonts.interStyle(
            size: 11,
            height: 16.5 / 11,
            color: const Color(0x80FFFFFF),
          ),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0x33FFFFFF)),
    );

    return Semantics(
      button: true,
      label: 'Notifications, $count unread',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: const Color(0x26FFFFFF),
              shape: shape,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: const Center(child: HomeIcon(HomeIcons.bell, size: 18)),
              ),
            ),
            Positioned(
              left: 24,
              top: 2,
              child: IgnorePointer(
                child: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.brandDot,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background),
                  ),
                  child: Text(
                    '$count',
                    textScaler: TextScaler.noScaling,
                    style: AppFonts.interStyle(
                      size: 8,
                      weight: FontWeight.w700,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: Divider(height: 1, thickness: 1, color: Colors.white10),
    );

    return Row(
      children: [
        line,
        const SizedBox(width: 8),
        Flexible(
          flex: 3,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppFonts.interStyle(
              size: 10,
              weight: FontWeight.w500,
              height: 1.5,
              color: const Color(0x66FFFFFF),
            ),
          ),
        ),
        const SizedBox(width: 8),
        line,
      ],
    );
  }
}
