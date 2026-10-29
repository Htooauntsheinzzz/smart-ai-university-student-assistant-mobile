import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Rounded, bordered surface with a shadow and optional ink feedback.
///
/// Shared by the home cards, tiles, chips and buttons so their decoration
/// comes from one place.
class HomeSurface extends StatelessWidget {
  const HomeSurface({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.radius = 16,
    this.borderColor = AppColors.fieldBorder,
    this.borderWidth = 1,
    this.shadows = const [],
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final double radius;

  /// `null` draws no border.
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow> shadows;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: borderColor == null
          ? BorderSide.none
          : BorderSide(color: borderColor!, width: borderWidth),
    );

    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, shadows: shadows),
      child: Material(
        color: color,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? Padding(padding: padding, child: child)
            : InkWell(
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              ),
      ),
    );
  }
}

/// Small rounded label used for categories and counters.
class HomeBadge extends StatelessWidget {
  const HomeBadge({
    super.key,
    required this.label,
    required this.textStyle,
    required this.background,
    this.borderColor,
    this.radius = 999,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  });

  final String label;
  final TextStyle textStyle;
  final Color background;
  final Color? borderColor;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(label, style: textStyle),
    );
  }
}

/// Section heading (Inter Bold 13) with an optional trailing widget.
class HomeSectionHeading extends StatelessWidget {
  const HomeSectionHeading({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppFonts.interStyle(
              size: 13,
              weight: FontWeight.w700,
              height: 19.5 / 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
