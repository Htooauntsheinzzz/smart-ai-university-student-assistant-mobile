import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_icons.dart';
import '../controllers/demo_chat_controller.dart';
import '../demo/chat_demo_data.dart';
import 'ai_chat_icons.dart';

/// Message composer (Figma node `33:141`): attachment button, growing text
/// field and Send button in a rounded input container on a white bar.
///
/// The app shell places it in the Scaffold's bottom slot above the
/// navigation bar while the AI Chat tab is selected, so SnackBars appear
/// above it rather than over it and it rises with the keyboard. Send appends
/// a local user message through the [DemoChatController] and says that no AI
/// reply exists yet. Send is disabled while the draft is blank, as in the
/// frame; the enabled state reuses the dark primary button treatment
/// (DEC-009).
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    this.hintText = ChatDemoData.composerHint,
    this.maxWidth = 600,
  });

  final DemoChatController controller;
  final String hintText;

  /// Widest the input container grows on tablets (Figma: 370 wide).
  final double maxWidth;

  static const String demoModeMessage =
      'Demo mode: AI responses are not connected yet.';
  static const String attachmentsUnavailableMessage =
      'Attachments are not available in this demo.';

  /// Height of the Send button, which the single-line field is centred on.
  static const double _buttonSize = 38;
  static const double _lineHeight = 19.5;

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _send(BuildContext context) {
    if (controller.send() == null) return;
    _showMessage(context, demoModeMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.fieldBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Row(
              // Buttons stay on the last line while the field grows upward.
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _AttachButton(
                  onTap: () =>
                      _showMessage(context, attachmentsUnavailableMessage),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: (_buttonSize - _lineHeight) / 2,
                    ),
                    child: TextField(
                      controller: controller.draft,
                      focusNode: controller.focusNode,
                      minLines: 1,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      // Enter inserts a newline; only the button sends.
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: AppColors.textPrimary,
                      style: AppFonts.interStyle(
                        size: 13,
                        height: _lineHeight / 13,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: hintText,
                        // A wrapped hint would make the empty field taller
                        // than one line on narrow screens with large text.
                        hintMaxLines: 1,
                        hintStyle: AppFonts.interStyle(
                          size: 13,
                          height: _lineHeight / 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller.draft,
                  builder: (context, value, _) => _SendButton(
                    enabled: DemoChatController.isSendable(value.text),
                    onTap: () => _send(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paperclip without a background, 36 wide and as tall as the Send button.
class _AttachButton extends StatelessWidget {
  const _AttachButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Attach file',
      excludeSemantics: true,
      child: SizedBox(
        width: 36,
        height: ChatComposer._buttonSize,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: const Center(child: HomeIcon(AiChatIcons.attach, size: 18)),
          ),
        ),
      ),
    );
  }
}

/// 38 dp Send button: grey and inactive while blank, dark with a white arrow
/// once there is text.
class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Send message',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          shadows: enabled ? AppShadows.darkButton : const [],
        ),
        child: Material(
          color: enabled ? AppColors.textPrimary : AppColors.fieldBorder,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: SizedBox.square(
              dimension: ChatComposer._buttonSize,
              child: Center(
                child: SvgPicture.asset(
                  AiChatIcons.send,
                  width: 15,
                  height: 15,
                  colorFilter: enabled
                      ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                      : null,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
