import '../models/chat_message.dart';
import '../widgets/ai_chat_icons.dart';

// DEMO DATA — static fixture content copied from the Figma frame
// `Ai-Chat Screen` (33:30). Nothing here comes from the backend or an AI
// model, and the status label is a preview string, not a connection check.
// Replace with the assistant endpoint when it is integrated (DEC-009).

/// A tappable prompt in the suggestion strip.
class SuggestedPrompt {
  const SuggestedPrompt({required this.text, required this.icon});

  final String text;
  final String icon;
}

abstract final class ChatDemoData {
  static const String title = 'AI Assistant';

  /// Fixed preview label from the frame; no connection is checked.
  static const String statusLabel = 'Online · Ready to help';

  static const String composerHint = 'Ask about your university…';

  /// Initial assistant message and its reference timestamp.
  static const greeting = ChatMessage(
    id: 'greeting',
    role: ChatRole.assistant,
    text: 'Hi Shein! How can I help with your university life today?',
    timeLabel: '09:00 AM',
  );

  /// The five prompts of the strip, in frame order.
  static const suggestedPrompts = [
    SuggestedPrompt(
      text: 'What classes do I have today?',
      icon: AiChatIcons.promptCalendar,
    ),
    SuggestedPrompt(
      text: 'Where is Building 11?',
      icon: AiChatIcons.promptLocation,
    ),
    SuggestedPrompt(
      text: 'What assignments are due this week?',
      icon: AiChatIcons.promptAssignment,
    ),
    SuggestedPrompt(
      text: 'When is my next exam?',
      icon: AiChatIcons.promptExam,
    ),
    SuggestedPrompt(
      text: 'Take me to my next class',
      icon: AiChatIcons.promptNavigate,
    ),
  ];
}
