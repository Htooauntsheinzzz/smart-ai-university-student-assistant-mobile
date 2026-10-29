import 'package:flutter/material.dart';

import '../../../auth/data/models/student_user.dart';
import '../demo/home_demo_data.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/announcements_section.dart';
import '../widgets/deadline_card.dart';
import '../widgets/home_header.dart';
import '../widgets/next_class_card.dart';
import '../widgets/quick_actions_grid.dart';

/// Home screen from the Figma frame `Home Page Screen` (node `3:209`).
///
/// Shown as a tab of the signed-in app shell, which supplies the Scaffold and
/// the shared bottom navigation (DEC-008). Shows static demo content
/// ([HomeDemoData]); no backend request is made. The AI card's actions open
/// the AI Chat tab through the shell (DEC-009); every other action belongs to
/// a feature that does not exist yet, so taps show a short "not implemented
/// yet" message and stay on Home (DEC-006).
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.student,
    required this.onOpenAssistant,
    required this.onAskAssistant,
  });

  /// Signed-in student used for the header's identity fields (DEC-010).
  final StudentUser student;

  /// Ask AI Assistant: open the chat with the composer as it is.
  final VoidCallback onOpenAssistant;

  /// A suggested question: open the chat with the question in the composer.
  final ValueChanged<String> onAskAssistant;

  /// Widest the cards grow on tablets (Figma cards are 370 wide).
  static const double _maxContentWidth = 600;

  static String notImplementedMessage(String feature) =>
      '$feature is not implemented yet.';

  void _notImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(notImplementedMessage(feature))));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(
            student: HomeDemoData.studentFor(student),
            onNotificationsTap: () => _notImplemented(context, 'Notifications'),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: _HomeContent(
                    onOpenAssistant: onOpenAssistant,
                    onAskAssistant: onAskAssistant,
                    onUnavailable: (feature) =>
                        _notImplemented(context, feature),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.onOpenAssistant,
    required this.onAskAssistant,
    required this.onUnavailable,
  });

  final VoidCallback onOpenAssistant;
  final ValueChanged<String> onAskAssistant;
  final ValueChanged<String> onUnavailable;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NextClassCard(
          nextClass: HomeDemoData.nextClass,
          onViewClass: () => onUnavailable('Class details'),
          onNavigate: () => onUnavailable('Campus navigation'),
        ),
        gap,
        AiAssistantCard(
          suggestions: HomeDemoData.suggestions,
          onSuggestionTap: (suggestion) => onAskAssistant(suggestion.label),
          onAskTap: onOpenAssistant,
        ),
        gap,
        QuickActionsGrid(
          actions: HomeDemoData.quickActions,
          onActionTap: (action) => onUnavailable(action.label),
        ),
        gap,
        UpcomingDeadlinesSection(
          badge: HomeDemoData.deadlinesBadge,
          deadlines: HomeDemoData.deadlines,
          onDeadlineTap: (_) => onUnavailable('Deadline details'),
        ),
        gap,
        AnnouncementsSection(
          announcements: HomeDemoData.announcements,
          onSeeAll: () => onUnavailable('Announcements'),
          onAnnouncementTap: (_) => onUnavailable('Announcement details'),
        ),
      ],
    );
  }
}
