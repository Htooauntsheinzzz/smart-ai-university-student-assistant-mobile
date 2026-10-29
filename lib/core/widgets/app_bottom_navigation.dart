import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_theme.dart';

/// Top-level destinations in the bottom navigation, in display order.
enum AppDestination {
  home('Home', 'assets/icons/nav/home.svg'),
  aiChat('AI Chat', 'assets/icons/nav/ai_chat.svg'),
  schedule('Schedule', 'assets/icons/nav/schedule.svg'),
  campus('Campus', 'assets/icons/nav/campus.svg'),
  profile('Profile', 'assets/icons/nav/profile.svg');

  const AppDestination(this.label, this.icon);

  final String label;

  /// Stroke icon exported from Figma (`3:595`); tinted per state.
  final String icon;
}

/// Fixed bottom navigation from the Figma home frame (node `3:595`).
///
/// Only renders the bar; the caller decides what a tap does.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppDestination selected;
  final ValueChanged<AppDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.fieldBorder)),
      ),
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        4 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Row(
        children: [
          for (final destination in AppDestination.values)
            Expanded(
              child: Center(
                heightFactor: 1,
                child: _NavItem(
                  destination: destination,
                  active: destination == selected,
                  onTap: () => onSelected(destination),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final AppDestination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.textPrimary : AppColors.textMuted;

    return Semantics(
      button: true,
      selected: active,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Material(
            color: active
                ? AppColors.textPrimary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        destination.icon,
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        excludeFromSemantics: true,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        destination.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: AppFonts.interStyle(
                          size: 9,
                          weight: FontWeight.w600,
                          height: 1.5,
                          letterSpacing: 0.225,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (active)
            // Indicator sits on the bar's top border, 8 above the item.
            Positioned(
              top: -8,
              child: Container(
                width: 24,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
