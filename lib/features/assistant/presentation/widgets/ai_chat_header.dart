import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_icons.dart';
import 'ai_chat_icons.dart';

/// Dark assistant header (Figma node `33:36`): robot badge, title with the
/// status line, history and New Chat buttons, over the decorative circle
/// artwork. The status is a fixed preview label, not a connection check.
class AiChatHeader extends StatelessWidget {
  const AiChatHeader({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.onHistoryTap,
    required this.onNewChatTap,
  });

  final String title;
  final String statusLabel;
  final VoidCallback onHistoryTap;
  final VoidCallback onNewChatTap;

  /// Figma reserves 58 for the status bar, then 12 before the content row.
  static const double _statusBarSpace = 58;
  static const double _decorationWidth = 402;
  static const double _decorationHeight = 130;

  /// Translucent white fill and border shared by the badge and buttons.
  static const BoxDecoration _glass = BoxDecoration(
    color: Color(0x26FFFFFF),
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: Color(0x33FFFFFF))),
  );

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
          // Drawn at its Figma size and centred, never scaled, so the circles
          // keep their proportions on every width.
          Positioned.fill(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minWidth: _decorationWidth,
              maxWidth: _decorationWidth,
              minHeight: _decorationHeight,
              maxHeight: _decorationHeight,
              child: SvgPicture.asset(
                AiChatIcons.headerDecoration,
                width: _decorationWidth,
                height: _decorationHeight,
                excludeFromSemantics: true,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 16),
            child: Row(
              children: [
                const _AssistantBadge(),
                const SizedBox(width: 12),
                Expanded(
                  child: _TitleAndStatus(
                    title: title,
                    statusLabel: statusLabel,
                  ),
                ),
                const SizedBox(width: 12),
                _HistoryButton(onTap: onHistoryTap),
                // The history touch area is 4 wider than its visual on each
                // side, so 8 here keeps the designed 12 between the visuals.
                const SizedBox(width: 8),
                _NewChatButton(onTap: onNewChatTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantBadge extends StatelessWidget {
  const _AssistantBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: AiChatHeader._glass.copyWith(boxShadow: AppShadows.card),
      child: const HomeIcon(AiChatIcons.headerRobot, size: 20),
    );
  }
}

class _TitleAndStatus extends StatelessWidget {
  const _TitleAndStatus({required this.title, required this.statusLabel});

  final String title;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Both lines are single-line in the frame; they truncate rather than
        // wrap when large text leaves them little width.
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.poppinsBold(
            size: 17,
            height: 21.25 / 17,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          // The dot is part of the text run so the whole line truncates
          // together instead of the dot overflowing a narrow column.
          child: Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                TextSpan(text: statusLabel),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.interStyle(
              size: 10,
              weight: FontWeight.w500,
              height: 1.5,
              color: const Color(0xB3FFFFFF),
            ),
          ),
        ),
      ],
    );
  }
}

/// 36 dp clock button inside a 44 dp touch area.
class _HistoryButton extends StatelessWidget {
  const _HistoryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Chat history',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 44,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: AiChatHeader._glass,
                child: const HomeIcon(AiChatIcons.history, size: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Plus icon and label in a 36 dp pill inside a 44 dp tall touch area.
class _NewChatButton extends StatelessWidget {
  const _NewChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: SizedBox(
        height: 44,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: AiChatHeader._glass,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HomeIcon(AiChatIcons.plus, size: 11),
                    const SizedBox(width: 6),
                    // Capped so the row still fits a 320 dp screen at the
                    // largest text size; the title gives way before this.
                    MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.3,
                      child: Text(
                        'New Chat',
                        maxLines: 1,
                        style: AppFonts.interStyle(
                          size: 10,
                          weight: FontWeight.w700,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
