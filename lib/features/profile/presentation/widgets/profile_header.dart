import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_icons.dart';
import '../demo/profile_demo_data.dart';
import 'profile_icons.dart';
import 'profile_stat_card.dart';

/// Dark profile header (Figma node `28:37`): page heading with the settings
/// button, avatar with its status badge, name, student ID, the three
/// statistic cards and the Edit Profile button, over the circle artwork.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.student,
    required this.stats,
    required this.onSettingsTap,
    required this.onEditProfileTap,
  });

  final ProfileStudent student;
  final List<ProfileStat> stats;
  final VoidCallback onSettingsTap;
  final VoidCallback onEditProfileTap;

  /// Figma reserves 58 for the status bar, then 16 before the heading row.
  static const double _statusBarSpace = 58;
  static const double _decorationHeight = 477.5;

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
          // Drawn at its Figma size (402 wide) and centred, so the circles
          // keep their proportions on every screen width.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _decorationHeight,
            child: SvgPicture.asset(
              ProfileIcons.headerDecoration,
              fit: BoxFit.none,
              alignment: Alignment.topCenter,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            // Bottom 28 + the Edit Profile button's 4 dp of tap-target padding
            // gives the frame's 32 below the visible button.
            padding: EdgeInsets.fromLTRB(20, top + 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeadingRow(onSettingsTap: onSettingsTap),
                // The row is 48 tall (settings touch target); 18.5 puts the
                // avatar at y = 140.5 as in the frame.
                const SizedBox(height: 18.5),
                Center(child: _Avatar(initial: student.initial)),
                const SizedBox(height: 16),
                Text(
                  student.name,
                  textAlign: TextAlign.center,
                  style: AppFonts.poppinsBlack(
                    size: 20,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${student.studentId}',
                  textAlign: TextAlign.center,
                  style: AppFonts.interStyle(
                    size: 13,
                    weight: FontWeight.w600,
                    height: 1.5,
                    color: const Color(0xB3FFFFFF),
                  ),
                ),
                const SizedBox(height: 16),
                // Cards keep their content width; if large text makes the
                // three too wide for the screen they wrap instead of clipping.
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final stat in stats) ProfileStatCard(stat: stat),
                  ],
                ),
                // 12 + the button's 4 dp tap-target padding = 16 visible.
                const SizedBox(height: 12),
                Center(child: _EditProfileButton(onTap: onEditProfileTap)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadingRow extends StatelessWidget {
  const _HeadingRow({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'STUDENT PORTAL',
                style: AppFonts.interStyle(
                  size: 9,
                  weight: FontWeight.w700,
                  height: 1.5,
                  letterSpacing: 0.9,
                  color: const Color(0x80FFFFFF),
                ),
              ),
              Semantics(
                header: true,
                child: Text(
                  'My Profile',
                  style: AppFonts.poppinsBlack(
                    size: 22,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // The 48 dp touch target centres the 42 dp button, which would leave
        // it 3 dp left of the frame; shift it so the visible button keeps the
        // frame's 20 dp right margin (the touch area moves with it).
        Transform.translate(
          offset: const Offset(3, 0),
          child: _SettingsButton(onTap: onSettingsTap),
        ),
      ],
    );
  }
}

/// 42 dp translucent settings button inside a 48 dp touch target.
class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Settings',
      onTap: onTap,
      excludeSemantics: true,
      child: IconButton(
        onPressed: onTap,
        icon: const HomeIcon(ProfileIcons.settings, size: 19),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0x26FFFFFF),
          fixedSize: const Size.square(42),
          minimumSize: const Size.square(42),
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Color(0x33FFFFFF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
    );
  }
}

/// Rounded-square initial avatar with the green check badge overlapping its
/// lower-right corner (Figma node `28:59`). Decorative: the name follows.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: 96,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x66FFFFFF), width: 2),
                boxShadow: AppShadows.card,
              ),
              child: Text(
                initial,
                textScaler: TextScaler.noScaling,
                style: AppFonts.poppinsBlack(
                  size: 36,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: 76,
              top: 76,
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentBlue, width: 2),
                ),
                child: const HomeIcon(ProfileIcons.badgeCheck, size: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White pill button with the pencil icon (Figma node `28:90`).
class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: AppFonts.interStyle(size: 12, height: 1.5),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HomeIcon(ProfileIcons.edit, size: 13),
          SizedBox(width: 8),
          Flexible(child: Text('Edit Profile', textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
