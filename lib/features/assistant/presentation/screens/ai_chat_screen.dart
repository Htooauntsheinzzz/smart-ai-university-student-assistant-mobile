import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../controllers/demo_chat_controller.dart';
import '../demo/chat_demo_data.dart';
import '../widgets/ai_chat_header.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/suggested_prompts_strip.dart';

/// AI Chat screen from the Figma frame `Ai-Chat Screen` (node `33:30`).
///
/// Shown as a tab of the signed-in app shell, which supplies the Scaffold,
/// the shared bottom navigation, the [DemoChatController] holding the
/// conversation, and the `ChatComposer` in the Scaffold's bottom slot. The
/// header and suggestion strip stay fixed; only the conversation scrolls.
/// Sending appends a local user message; no AI reply, request or history
/// exists yet (DEC-009).
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key, required this.controller});

  final DemoChatController controller;

  static const String historyUnavailableMessage =
      'Chat history is not available in this demo.';
  static const String draftInUseMessage =
      'Send or clear your current message first.';
  static const String newChatDialogTitle = 'Start a new chat?';
  static const String newChatDialogMessage =
      'This will clear the current demo conversation.';

  /// Widest the messages grow on tablets (Figma: 370 wide).
  static const double _maxContentWidth = 600;

  /// Below this body height (keyboard open on a small phone) the suggestion
  /// strip is left out so some conversation still fits under the header.
  static const double compactHeight = 300;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _scrollController = ScrollController();

  /// Last seen message count, to scroll only when the conversation changes.
  /// Set eagerly in [initState]: a lazy initialiser would first run inside
  /// the listener, after the change, and never see it.
  int _messageCount = 0;

  @override
  void initState() {
    super.initState();
    _messageCount = widget.controller.messages.length;
    widget.controller.addListener(_onConversationChanged);
  }

  @override
  void didUpdateWidget(AiChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onConversationChanged);
      widget.controller.addListener(_onConversationChanged);
      _messageCount = widget.controller.messages.length;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onConversationChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// A new message scrolls to the end; a reset returns to the top. Other
  /// rebuilds leave the scroll position alone.
  void _onConversationChanged() {
    final count = widget.controller.messages.length;
    if (count > _messageCount) {
      _afterLayout((position) {
        _scrollController.animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    } else if (count < _messageCount) {
      _afterLayout((position) => _scrollController.jumpTo(0));
    }
    _messageCount = count;
  }

  /// Runs [action] once the updated list has been laid out.
  void _afterLayout(ValueChanged<ScrollPosition> action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      action(_scrollController.position);
    });
  }

  void _onPromptTap(SuggestedPrompt prompt) {
    if (!widget.controller.prefill(prompt.text)) {
      _showMessage(AiChatScreen.draftInUseMessage);
      return;
    }
    widget.controller.focusNode.requestFocus();
  }

  Future<void> _onNewChat() async {
    widget.controller.focusNode.unfocus();
    if (widget.controller.needsResetConfirmation) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => const _NewChatDialog(),
      );
      if (confirmed != true || !mounted) return;
    }
    widget.controller.reset();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < AiChatScreen.compactHeight;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AiChatHeader(
              title: ChatDemoData.title,
              statusLabel: ChatDemoData.statusLabel,
              onHistoryTap: () =>
                  _showMessage(AiChatScreen.historyUnavailableMessage),
              onNewChatTap: _onNewChat,
            ),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!compact)
                      SuggestedPromptsStrip(
                        prompts: ChatDemoData.suggestedPrompts,
                        onPromptTap: _onPromptTap,
                      ),
                    Expanded(
                      child: _ConversationList(
                        controller: widget.controller,
                        scrollController: _scrollController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Scrollable message list (Figma node `33:121`) on the page background.
class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.controller,
    required this.scrollController,
  });

  final DemoChatController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final messages = controller.messages;
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: messages.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final message = messages[index];
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AiChatScreen._maxContentWidth,
                ),
                child: ChatMessageBubble(
                  key: ValueKey(message.id),
                  message: message,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Confirmation before New Chat discards user messages or a draft. An added
/// local interaction, not part of the inspected frame.
class _NewChatDialog extends StatelessWidget {
  const _NewChatDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        AiChatScreen.newChatDialogTitle,
        style: AppFonts.poppinsBold(size: 16, color: AppColors.textPrimary),
      ),
      content: Text(
        AiChatScreen.newChatDialogMessage,
        style: AppFonts.interStyle(
          size: 13,
          height: 1.5,
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            textStyle: AppFonts.interStyle(size: 13, weight: FontWeight.w600),
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppFonts.interStyle(size: 13, weight: FontWeight.w600),
          ),
          child: const Text('New Chat'),
        ),
      ],
    );
  }
}
