import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../demo/home_demo_data.dart';
import 'home_icons.dart';
import 'home_surface.dart';

/// "Quick Actions" section (Figma node `3:392`).
///
/// Built from rows rather than a scrollable grid so it never competes with
/// the page scroll, and so tile height follows the label at large text sizes.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  final List<HomeQuickAction> actions;
  final ValueChanged<HomeQuickAction> onActionTap;

  static const double _gap = 10;

  /// Below this tile width (at the current text scale) use two columns.
  static const double _minTileWidth = 96;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HomeSectionHeading(title: 'Quick Actions'),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final threeColumnWidth = (constraints.maxWidth - 2 * _gap) / 3;
            final columns = threeColumnWidth / textScale >= _minTileWidth
                ? 3
                : 2;
            return Column(
              children: [
                for (var start = 0; start < actions.length; start += columns)
                  Padding(
                    padding: EdgeInsets.only(top: start == 0 ? 0 : _gap),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = start; i < start + columns; i++) ...[
                            if (i > start) const SizedBox(width: _gap),
                            Expanded(
                              child: i < actions.length
                                  ? _QuickActionTile(
                                      action: actions[i],
                                      onTap: () => onActionTap(actions[i]),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, required this.onTap});

  final HomeQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeSurface(
      shadows: AppShadows.raised,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: action.iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: HomeIcon(action.icon, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            textAlign: TextAlign.center,
            style: AppFonts.interStyle(
              size: 10,
              weight: FontWeight.w700,
              height: 1.25,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
