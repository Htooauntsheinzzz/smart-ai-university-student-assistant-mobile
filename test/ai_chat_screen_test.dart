import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_ai_university_student_assistant/app/shell/app_shell.dart';
import 'package:smart_ai_university_student_assistant/core/widgets/app_bottom_navigation.dart';
import 'package:smart_ai_university_student_assistant/features/assistant/presentation/demo/chat_demo_data.dart';
import 'package:smart_ai_university_student_assistant/features/assistant/presentation/screens/ai_chat_screen.dart';
import 'package:smart_ai_university_student_assistant/features/assistant/presentation/widgets/chat_composer.dart';
import 'package:smart_ai_university_student_assistant/features/assistant/presentation/widgets/chat_message_bubble.dart';
import 'package:smart_ai_university_student_assistant/features/assistant/presentation/widgets/suggested_prompts_strip.dart';
import 'package:smart_ai_university_student_assistant/features/home/presentation/screens/home_screen.dart';

import 'support/auth_fakes.dart';

/// Pumps the signed-in shell on [tab] at the Figma reference size (402 × 874)
/// unless [size] is given. [keyboard] simulates a keyboard of that height.
Future<void> _pumpShell(
  WidgetTester tester, {
  AppDestination tab = AppDestination.aiChat,
  Size size = const Size(402, 874),
  double keyboard = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: AppShell(
        student: buildStudent(
          firstName: 'Shein',
          programName: 'Computer Science',
          academicYear: 3,
        ),
        onLogout: () async {},
        initialDestination: tab,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _composer() => find.byType(TextField);
Finder _sendButton() => find.bySemanticsLabel('Send message');
Finder _bubbles() => find.byType(ChatMessageBubble);
Finder _promptsScrollable() => find.descendant(
  of: find.byType(SuggestedPromptsStrip),
  matching: find.byType(Scrollable),
);
Finder _homeScrollable() => find.descendant(
  of: find.byType(HomeScreen),
  matching: find.byType(Scrollable),
);

AppDestination _selectedTab(WidgetTester tester) => tester
    .widget<AppBottomNavigation>(find.byType(AppBottomNavigation))
    .selected;

TextField _field(WidgetTester tester) => tester.widget<TextField>(_composer());

String _draft(WidgetTester tester) => _field(tester).controller!.text;

bool _sendEnabled(WidgetTester tester) =>
    tester
        .widget<InkWell>(
          find.descendant(of: _sendButton(), matching: find.byType(InkWell)),
        )
        .onTap !=
    null;

/// Types [text] into the composer and taps Send.
Future<void> _send(WidgetTester tester, String text) async {
  await tester.enterText(_composer(), text);
  await tester.pump();
  await tester.tap(_sendButton());
  await tester.pumpAndSettle();
}

/// Scrolls the Home tab to [finder] and taps it.
Future<void> _tapOnHome(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: _homeScrollable());
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'AI Chat renders the header, suggestions, greeting and composer',
    (WidgetTester tester) async {
      await _pumpShell(tester);

      expect(find.text(ChatDemoData.title), findsOneWidget);
      expect(find.textContaining(ChatDemoData.statusLabel), findsOneWidget);
      expect(find.bySemanticsLabel('Chat history'), findsOneWidget);
      expect(find.text('New Chat'), findsOneWidget);
      expect(find.text('SUGGESTED'), findsOneWidget);
      for (final prompt in ChatDemoData.suggestedPrompts) {
        expect(find.text(prompt.text), findsOneWidget);
      }
      expect(_bubbles(), findsOneWidget);
      expect(find.text(ChatDemoData.greeting.text), findsOneWidget);
      expect(find.text(ChatDemoData.greeting.timeLabel), findsOneWidget);
      expect(find.text(ChatDemoData.composerHint), findsOneWidget);
      expect(find.bySemanticsLabel('Attach file'), findsOneWidget);
      expect(_sendEnabled(tester), isFalse);
      expect(_draft(tester), isEmpty);

      final nav = find.byType(AppBottomNavigation);
      expect(nav, findsOneWidget);
      expect(_selectedTab(tester), AppDestination.aiChat);
      expect(
        tester.getSemantics(
          find.descendant(of: nav, matching: find.text('AI Chat')),
        ),
        isSemantics(isSelected: true, isButton: true),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('All five suggestions are reachable by scrolling the strip', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);
    final first = find.text(ChatDemoData.suggestedPrompts.first.text);
    final last = find.text(ChatDemoData.suggestedPrompts.last.text);
    expect(first.hitTestable(), findsOneWidget);
    expect(last.hitTestable(), findsNothing);

    await tester.scrollUntilVisible(
      last,
      100,
      scrollable: _promptsScrollable(),
    );
    await tester.pumpAndSettle();

    expect(last.hitTestable(), findsOneWidget);
    // One row: the last chip sits level with the first, not below it.
    expect(
      tester.getRect(last).center.dy,
      closeTo(tester.getRect(first).center.dy, 0.5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('A suggestion fills the composer without sending', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);
    final prompt = ChatDemoData.suggestedPrompts.first;

    await tester.tap(find.text(prompt.text));
    await tester.pumpAndSettle();

    expect(_draft(tester), prompt.text);
    expect(
      _field(tester).controller!.selection,
      TextSelection.collapsed(offset: prompt.text.length),
    );
    expect(_field(tester).focusNode!.hasFocus, isTrue);
    expect(_sendEnabled(tester), isTrue);
    expect(_bubbles(), findsOneWidget);
    expect(find.text(ChatComposer.demoModeMessage), findsNothing);

    // A different draft is kept and the user is told.
    await tester.enterText(_composer(), 'My own question');
    await tester.pump();
    await tester.tap(find.text(prompt.text));
    await tester.pumpAndSettle();

    expect(_draft(tester), 'My own question');
    expect(find.text(AiChatScreen.draftInUseMessage), findsOneWidget);
    expect(_bubbles(), findsOneWidget);
  });

  testWidgets('Send adds one local user message and clears the composer', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);

    await tester.enterText(_composer(), '   \n ');
    await tester.pump();
    expect(_sendEnabled(tester), isFalse);
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();
    expect(_bubbles(), findsOneWidget);

    await _send(tester, '  Where is the library?  ');

    expect(_bubbles(), findsNWidgets(2));
    final sent = find.text('Where is the library?');
    expect(sent, findsOneWidget);
    expect(_draft(tester), isEmpty);
    expect(_sendEnabled(tester), isFalse);
    expect(find.text(ChatComposer.demoModeMessage), findsOneWidget);
    // The greeting and one local timestamp; no assistant reply was added.
    expect(find.text(ChatDemoData.greeting.text), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'^\d{2}:\d{2} (AM|PM)$')),
      findsNWidgets(2),
    );
    // The user bubble is right-aligned.
    final greeting = tester.getRect(find.text(ChatDemoData.greeting.text));
    expect(tester.getRect(sent).right, greaterThan(greeting.right));
    expect(tester.getRect(sent).right, lessThanOrEqualTo(402 - 16));

    // Send is inactive again, so another tap adds nothing.
    await tester.tap(_sendButton());
    await tester.pumpAndSettle();
    expect(_bubbles(), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('New Chat asks before clearing and restores the greeting', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);

    // Nothing to lose: resets at once without a dialog.
    await tester.tap(find.text('New Chat'));
    await tester.pumpAndSettle();
    expect(find.text(AiChatScreen.newChatDialogTitle), findsNothing);
    expect(_bubbles(), findsOneWidget);

    await _send(tester, 'Hello');
    await tester.enterText(_composer(), 'Unsent draft');
    await tester.pump();

    await tester.tap(find.text('New Chat'));
    await tester.pumpAndSettle();
    expect(find.text(AiChatScreen.newChatDialogTitle), findsOneWidget);
    expect(find.text(AiChatScreen.newChatDialogMessage), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text(AiChatScreen.newChatDialogTitle), findsNothing);
    expect(_bubbles(), findsNWidgets(2));
    expect(_draft(tester), 'Unsent draft');

    await tester.tap(find.text('New Chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'New Chat'));
    await tester.pumpAndSettle();

    expect(find.text(AiChatScreen.newChatDialogTitle), findsNothing);
    expect(_bubbles(), findsOneWidget);
    expect(find.text(ChatDemoData.greeting.text), findsOneWidget);
    expect(find.text(ChatDemoData.greeting.timeLabel), findsOneWidget);
    expect(find.text('Hello'), findsNothing);
    expect(_draft(tester), isEmpty);
    expect(_field(tester).focusNode!.hasFocus, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('History and attachment controls say they are unavailable', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);

    await tester.tap(find.bySemanticsLabel('Chat history'));
    await tester.pumpAndSettle();
    expect(find.text(AiChatScreen.historyUnavailableMessage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Attach file'));
    await tester.pumpAndSettle();
    expect(
      find.text(ChatComposer.attachmentsUnavailableMessage),
      findsOneWidget,
    );
    expect(find.text(AiChatScreen.historyUnavailableMessage), findsNothing);

    expect(find.byType(AiChatScreen), findsOneWidget);
    expect(_selectedTab(tester), AppDestination.aiChat);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('Home AI actions open the AI Chat tab', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, tab: AppDestination.home);

    await _tapOnHome(tester, find.text('Ask AI Assistant'));
    expect(_selectedTab(tester), AppDestination.aiChat);
    expect(find.text(ChatDemoData.title).hitTestable(), findsOneWidget);
    expect(find.text('Good Evening').hitTestable(), findsNothing);
    expect(_draft(tester), isEmpty);
    expect(_bubbles(), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await _tapOnHome(tester, find.text('Any assignments due?'));
    expect(_selectedTab(tester), AppDestination.aiChat);
    expect(_draft(tester), 'Any assignments due?');
    expect(
      _field(tester).controller!.selection,
      const TextSelection.collapsed(offset: 'Any assignments due?'.length),
    );
    expect(_bubbles(), findsOneWidget);
    expect(find.text(ChatComposer.demoModeMessage), findsNothing);

    // An existing different draft is kept.
    await tester.enterText(_composer(), 'Keep me');
    await tester.pump();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await _tapOnHome(tester, find.text('Take me to next class'));
    expect(_selectedTab(tester), AppDestination.aiChat);
    expect(_draft(tester), 'Keep me');
    expect(find.text(AiChatScreen.draftInUseMessage), findsOneWidget);

    expect(find.byType(AppBottomNavigation), findsOneWidget);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Conversation and draft survive switching tabs', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);
    await _send(tester, 'Hello there');
    await tester.enterText(_composer(), 'Draft text');
    await tester.pump();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), AppDestination.profile);
    expect(find.text(ChatDemoData.title).hitTestable(), findsNothing);

    await tester.tap(find.text('AI Chat'));
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), AppDestination.aiChat);
    expect(_bubbles(), findsNWidgets(2));
    expect(find.text('Hello there').hitTestable(), findsOneWidget);
    expect(_draft(tester), 'Draft text');
    expect(find.byType(AppBottomNavigation), findsOneWidget);

    // Tapping the current tab changes nothing.
    await tester.tap(find.text('AI Chat'));
    await tester.pumpAndSettle();
    expect(_bubbles(), findsNWidgets(2));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);

    // Tabs without a screen show a message and keep AI Chat selected.
    await tester.tap(find.text('Campus'));
    await tester.pumpAndSettle();
    expect(
      find.text(HomeScreen.notImplementedMessage('Campus')),
      findsOneWidget,
    );
    expect(_selectedTab(tester), AppDestination.aiChat);
  });

  testWidgets('The composer stays above the keyboard', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, keyboard: 300);

    expect(tester.takeException(), isNull);
    expect(find.text('SUGGESTED'), findsOneWidget);
    expect(tester.getTopLeft(find.text(ChatDemoData.title)).dy, lessThan(130));
    expect(
      tester.getRect(find.byType(ChatComposer)).bottom,
      lessThanOrEqualTo(874 - 300),
    );
    expect(_composer().hitTestable(), findsOneWidget);
    expect(_sendButton().hitTestable(), findsOneWidget);
  });

  testWidgets('A small phone with large text and the keyboard open still '
      'shows the composer', (WidgetTester tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpShell(tester, size: const Size(320, 568), keyboard: 300);

    expect(tester.takeException(), isNull);
    // The suggestion strip gives way on such a short body (DEC-009).
    expect(find.text('SUGGESTED'), findsNothing);
    expect(find.text(ChatDemoData.title), findsOneWidget);
    expect(
      tester.getRect(find.byType(ChatComposer)).bottom,
      lessThanOrEqualTo(568 - 300),
    );
    expect(_composer().hitTestable(), findsOneWidget);
    expect(_sendButton().hitTestable(), findsOneWidget);
  });

  testWidgets('AI Chat does not overflow on a small device with large text', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpShell(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);
    expect(find.text('SUGGESTED'), findsOneWidget);

    const long =
        'A long message that has to wrap onto several lines because the '
        'screen is narrow and the text is large, without any overflow.';
    await _send(tester, long);
    expect(tester.takeException(), isNull);

    final text = find.text(long);
    expect(tester.getRect(text).left, greaterThanOrEqualTo(16));
    expect(tester.getRect(text).right, lessThanOrEqualTo(320 - 16));
    // Wrapped onto several lines rather than clipped.
    expect(tester.getSize(text).height, greaterThan(60));
  });
}
