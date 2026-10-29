import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_ai_university_student_assistant/app/shell/app_shell.dart';
import 'package:smart_ai_university_student_assistant/core/widgets/app_bottom_navigation.dart';
import 'package:smart_ai_university_student_assistant/features/home/presentation/screens/home_screen.dart';

import 'support/auth_fakes.dart';

/// Pumps the signed-in shell on Home at the Figma reference size
/// (402 × 874) unless [size] is given, with an authenticated student
/// whose programme is "Computer Science" and academic year 3 so the
/// greeting header is populated.
Future<void> _pumpHome(
  WidgetTester tester, {
  Size size = const Size(402, 874),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: AppShell(
        student: buildStudent(programName: 'Computer Science', academicYear: 3),
        onLogout: () async {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _scrollable() => find.byType(Scrollable).first;

void main() {
  testWidgets('Home renders the identity header and the first sections', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    // Identity bits come from the authenticated student (DEC-010).
    expect(find.text('Shein'), findsOneWidget);
    expect(find.text('Computer Science · Year 3'), findsOneWidget);
    // Everything else keeps its fixture content.
    expect(find.text('NEXT CLASS'), findsOneWidget);
    expect(find.text('Mobile Programming'), findsOneWidget);
    expect(find.text('How can I help you today?'), findsOneWidget);
    expect(find.text('Ask AI Assistant'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Quick Actions shows the seven tiles in order', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);
    await tester.scrollUntilVisible(
      find.text('University'),
      200,
      scrollable: _scrollable(),
    );

    const labels = [
      'Timetable',
      'Campus Map',
      'Assignments',
      'Exams',
      'Study Assist',
      'My Courses',
      'University',
    ];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    final timetable = tester.getRect(find.text('Timetable'));
    expect(
      tester.getRect(find.text('Assignments')).center.dy,
      timetable.center.dy,
    );
    final exams = tester.getRect(find.text('Exams'));
    final university = tester.getRect(find.text('University'));
    expect(university.center.dx, closeTo(timetable.center.dx, 0.5));
    expect(university.center.dy, greaterThan(exams.center.dy));
  });

  testWidgets('Page scrolls to the deadlines and announcements', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    expect(find.text('Network Lab Report').hitTestable(), findsNothing);
    await tester.drag(_scrollable(), const Offset(0, -3000));
    await tester.pumpAndSettle();

    expect(find.text('Upcoming Deadlines'), findsOneWidget);
    expect(find.text('1 due today'), findsOneWidget);
    expect(find.text('Mobile UI Prototype'), findsOneWidget);
    expect(find.text('Data Structures Midterm'), findsOneWidget);
    expect(find.text('Network Lab Report'), findsOneWidget);
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
    expect(
      find.text('RSU Sports Day Registration Now Open').hitTestable(),
      findsOneWidget,
    );
    expect(find.text('Profile').hitTestable(), findsOneWidget);
  });

  testWidgets('Bottom navigation has five items with Home selected', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    final nav = find.byType(AppBottomNavigation);
    for (final label in ['Home', 'AI Chat', 'Schedule', 'Campus', 'Profile']) {
      expect(
        find.descendant(of: nav, matching: find.text(label)),
        findsOneWidget,
      );
    }
    expect(
      tester.widget<AppBottomNavigation>(nav).selected,
      AppDestination.home,
    );
    expect(
      tester.getSemantics(
        find.descendant(of: nav, matching: find.text('Home')),
      ),
      isSemantics(isSelected: true, isButton: true),
    );
  });

  testWidgets('Unavailable actions show a message and stay on Home', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.text('Schedule'));
    await tester.pump();
    expect(
      find.text(HomeScreen.notImplementedMessage('Schedule')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<AppBottomNavigation>(find.byType(AppBottomNavigation))
          .selected,
      AppDestination.home,
    );

    await tester.tap(find.text('Navigate'));
    await tester.pump();
    expect(
      find.text(HomeScreen.notImplementedMessage('Campus navigation')),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel('Notifications, 0 unread'));
    await tester.pump();
    expect(
      find.text(HomeScreen.notImplementedMessage('Notifications')),
      findsOneWidget,
    );

    expect(find.byType(HomeScreen), findsOneWidget);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('Home does not overflow on a small device with large text', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpHome(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('RSU Sports Day Registration Now Open'),
      300,
      scrollable: _scrollable(),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
