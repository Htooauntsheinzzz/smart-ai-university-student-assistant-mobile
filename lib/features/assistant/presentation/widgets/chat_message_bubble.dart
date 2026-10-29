import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_icons.dart';
import '../models/chat_message.dart';
import 'ai_chat_icons.dart';

/// One conversation row: the assistant bubble with its blue robot avatar
/// (Figma node `33:122`), or the right-aligned dark user bubble.
///
/// The inspected frame only shows an assistant message; the user style is an
/// implementation addition to make local sending visible (DEC-009).
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  /// Widest a bubble grows; the frame's bubble is 303.4 wide.
  static const double maxBubbleWidth = 303.4;

  @override
  Widget build(BuildContext context) {
    return switch (message.role) {
      ChatRole.assistant => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: _AssistantAvatar(),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: _BubbleColumn(
              timeLabel: message.timeLabel,
              alignment: CrossAxisAlignment.start,
              bubble: _Bubble.assistant(message.text),
            ),
          ),
        ],
      ),
      ChatRole.user => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: _BubbleColumn(
              timeLabel: message.timeLabel,
              alignment: CrossAxisAlignment.end,
              bubble: _Bubble.user(message.text),
            ),
          ),
        ],
      ),
    };
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accentBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.blueRaised,
      ),
      child: const HomeIcon(AiChatIcons.avatarRobot, size: 17),
    );
  }
}

/// Bubble with the muted timestamp 4 dp below it, inset by 4 dp.
class _BubbleColumn extends StatelessWidget {
  const _BubbleColumn({
    required this.timeLabel,
    required this.alignment,
    required this.bubble,
  });

  final String timeLabel;
  final CrossAxisAlignment alignment;
  final Widget bubble;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ChatMessageBubble.maxBubbleWidth,
          ),
          child: bubble,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            timeLabel,
            style: AppFonts.interStyle(
              size: 9,
              height: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble.assistant(this.text)
    : color = Colors.white,
      borderColor = AppColors.fieldBorder,
      textColor = AppColors.textPrimary,
      shadows = AppShadows.raised,
      smallCorner = Alignment.topLeft;

  const _Bubble.user(this.text)
    : color = AppColors.textPrimary,
      borderColor = AppColors.avatar,
      textColor = Colors.white,
      shadows = AppShadows.darkButton,
      smallCorner = Alignment.topRight;

  final String text;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final List<BoxShadow> shadows;

  /// Which top corner gets the 6 dp radius; the others are 24.
  final Alignment smallCorner;

  @override
  Widget build(BuildContext context) {
    const small = Radius.circular(6);
    const large = Radius.circular(24);
    final leftIsSmall = smallCorner == Alignment.topLeft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.only(
          topLeft: leftIsSmall ? small : large,
          topRight: leftIsSmall ? large : small,
          bottomLeft: large,
          bottomRight: large,
        ),
        boxShadow: shadows,
      ),
      child: Text(
        text,
        style: AppFonts.interStyle(
          size: 12,
          height: 19.5 / 12,
          color: textColor,
        ),
      ),
    );
  }
}
