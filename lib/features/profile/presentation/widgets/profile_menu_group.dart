import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_surface.dart';
import '../demo/profile_demo_data.dart';
import 'profile_menu_tile.dart';

/// White grouped card of [ProfileMenuTile]s separated by thin dividers
/// (Figma nodes `28:196`, `28:215`, `28:258`).
class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  final List<ProfileMenuItem> items;
  final ValueChanged<ProfileMenuItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return HomeSurface(
      radius: 24,
      borderColor: AppColors.cardBorder,
      shadows: AppShadows.card,
      child: Column(
        children: [
          for (final (index, item) in items.indexed) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.pageBackground,
              ),
            ProfileMenuTile(item: item, onTap: () => onItemTap(item)),
          ],
        ],
      ),
    );
  }
}
