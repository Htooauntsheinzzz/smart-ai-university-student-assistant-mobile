import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_icons.dart';
import '../../../home/presentation/widgets/home_surface.dart';
import '../demo/profile_demo_data.dart';

/// White card listing the student's academic details (Figma node `28:103`).
/// The rows are display-only, separated by thin dividers.
class StudentInformationCard extends StatelessWidget {
  const StudentInformationCard({super.key, required this.rows});

  final List<ProfileInfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return HomeSurface(
      radius: 24,
      borderColor: AppColors.cardBorder,
      shadows: AppShadows.card,
      child: Column(
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.pageBackground,
              ),
            _InformationRow(row: row),
          ],
        ],
      ),
    );
  }
}

/// Icon, label and right-aligned value; grows when the value wraps.
class _InformationRow extends StatelessWidget {
  const _InformationRow({required this.row});

  final ProfileInfoRow row;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HomeIcon(row.icon, size: 16),
              ),
              const SizedBox(width: 12),
              // The label keeps its own width up to a third of the row; the
              // value gets the rest (180 of 368 in Figma) and wraps if needed.
              Flexible(
                child: Text(
                  row.label,
                  style: AppFonts.interStyle(
                    size: 11,
                    weight: FontWeight.w600,
                    height: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  row.value,
                  textAlign: TextAlign.end,
                  style: AppFonts.interStyle(
                    size: 11,
                    weight: FontWeight.w700,
                    height: 15.125 / 11,
                    color: AppColors.textPrimary,
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
