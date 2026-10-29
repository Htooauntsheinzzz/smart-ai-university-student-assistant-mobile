import 'package:flutter/widgets.dart';

import '../demo/chat_demo_data.dart';
import '../models/chat_message.dart';

/// In-memory state of the demo conversation: the message list, the composer
/// draft and the composer's focus (DEC-009).
///
/// Owned by the signed-in app shell so the conversation and draft survive
/// tab switches and are dropped with the shell on logout. Sending appends a
/// local user message only; no reply is generated and no request is made.
/// Nothing is persisted or logged.
class DemoChatController extends ChangeNotifier {
  DemoChatController({DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// Clock for user-message timestamps; injectable for tests.
  final DateTime Function() _now;

  /// Composer text; the text field and this controller share it.
  final TextEditingController draft = TextEditingController();

  /// Composer focus, shared so prompts can focus it and New Chat can
  /// dismiss the keyboard.
  final FocusNode focusNode = FocusNode(debugLabel: 'Chat composer');

  List<ChatMessage> _messages = const [ChatDemoData.greeting];
  int _nextId = 1;

  /// Messages in display order, starting with the greeting.
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool get hasUserMessages =>
      _messages.any((message) => message.role == ChatRole.user);

  /// Whether [text] has anything to send once trimmed.
  static bool isSendable(String text) => text.trim().isNotEmpty;

  bool get canSend => isSendable(draft.text);

  /// Whether New Chat should ask first: a user message or a draft exists.
  bool get needsResetConfirmation => hasUserMessages || isSendable(draft.text);

  /// Puts [text] in the composer with the cursor at its end, without sending.
  ///
  /// Returns `false` and leaves the composer alone when a different
  /// non-blank draft is already there, so a prompt never silently replaces
  /// what the user typed.
  bool prefill(String text) {
    final current = draft.text;
    if (isSendable(current) && current != text) return false;
    draft.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    return true;
  }

  /// Appends the trimmed draft as a user message and clears the composer.
  ///
  /// Returns `null` without changes for a blank draft, so a repeated tap
  /// cannot add the same text twice.
  ChatMessage? send() {
    final text = draft.text.trim();
    if (text.isEmpty) return null;
    final message = ChatMessage(
      id: 'user-${_nextId++}',
      role: ChatRole.user,
      text: text,
      timeLabel: formatTime(_now()),
    );
    _messages = [..._messages, message];
    draft.clear();
    notifyListeners();
    return message;
  }

  /// Restores the initial greeting and clears the draft.
  void reset() {
    _messages = const [ChatDemoData.greeting];
    draft.clear();
    notifyListeners();
  }

  /// Formats [time] like the frame's `09:00 AM` label.
  static String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final hh = hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm ${time.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  void dispose() {
    draft.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
