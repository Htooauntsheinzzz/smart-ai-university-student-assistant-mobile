/// Who wrote a chat message.
enum ChatRole { assistant, user }

/// One message of the local demo conversation (DEC-009).
///
/// Messages live in memory only; nothing is persisted or logged.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timeLabel,
  });

  /// Stable within a conversation, used as the list item key.
  final String id;
  final ChatRole role;
  final String text;

  /// Clock time shown under the bubble, e.g. `09:00 AM`.
  final String timeLabel;
}
