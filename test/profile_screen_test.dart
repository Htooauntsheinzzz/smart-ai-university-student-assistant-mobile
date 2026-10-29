import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_ai_university_student_assistant/app/shell/app_shell.dart';
import 'package:smart_ai_university_student_assistant/core/widgets/app_bottom_navigation.dart';
import 'package:smart_ai_university_student_assistant/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_ai_university_student_assistant/features/home/presentation/screens/home_screen.dart';
import 'package:smart_ai_university_student_assistant/features/profile/presentation/demo/profile_demo_data.dart';
import 'package:smart_ai_university_student_assistant/features/profile/presentation/screens/profile_screen.dart';

import 'support/auth_fakes.dart';

/// Pumps the signed-in shell on [tab] at the Figma reference size
/// (402 × 874) unless [size] is given. The logout callback flips the
/// [logoutCalled] flag so tests can assert that it fired.
Future<_LogoutProbe> _pumpShell(
  WidgetTester tester, {
  AppDestination tab = AppDestination.profile,
  Size size = const Size(402, 874),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final probe = _LogoutProbe();
  await tester.pumpWidget(
    MaterialApp(
      home: AppShell(
        student: buildStudent(firstName: 'Shein', studentCode: '6512345678'),
        onLogout: probe.call,
        initialDestination: tab,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return probe;
}

class _LogoutProbe {
  int calls = 0;
  Future<void> call() async {
    calls++;
  }
}

Finder _profileScrollable() => find.descendant(
  of: find.byType(ProfileScreen),
  matching: find.byType(Scrollable),
);

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: _profileScrollable(),
  );
  await tester.pumpAndSettle();
}

AppDestination _selectedTab(WidgetTester tester) => tester
    .widget<AppBottomNavigation>(find.byType(AppBottomNavigation))
    .selected;

Future<void> _tapExpectingMessage(
  WidgetTester tester,
  Finder finder,
  String message,
) async {
  await _scrollTo(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(find.text(message), findsOneWidget);
}

void main() {
  testWidgets('Profile renders the heading, identity, statistics and button', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);

    expect(find.text('STUDENT PORTAL'), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
    expect(find.text('Shein'), findsOneWidget);
    expect(find.text('ID: 6512345678'), findsOneWidget);
    for (final stat in ProfileDemoData.stats) {
      expect(find.text(stat.value), findsOneWidget);
      expect(find.text(stat.label), findsOneWidget);
    }
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('STUDENT INFORMATION'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Student Information lists the seven rows in order, with the real email',
    (WidgetTester tester) async {
      final probe = await _pumpShell(tester);
      // Suppress analyzer warning: probe is unused here.
      expect(probe.calls, 0);
      await _scrollTo(tester, find.text('Email'));

      final student = buildStudent(
        firstName: 'Shein',
        studentCode: '6512345678',
      );
      final rows = ProfileDemoData.informationFor(student);
      double? previousTop;
      for (final row in rows) {
        expect(find.text(row.label), findsOneWidget);
        expect(find.text(row.value), findsAtLeastNWidgets(1));
        final top = tester.getTopLeft(find.text(row.label)).dy;
        if (previousTop != null) expect(top, greaterThan(previousTop));
        previousTop = top;
      }
      // The Email row carries the authenticated student's email.
      expect(find.text(student.universityEmail), findsOneWidget);
      // The long Faculty value wraps instead of being clipped.
      final faculty = find.text('Faculty of Information Technology');
      expect(tester.getSize(faculty).height, greaterThan(20));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Every section is reachable while the navigation stays fixed', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);

    expect(find.text('Logout').hitTestable(), findsNothing);
    await tester.drag(_profileScrollable(), const Offset(0, -3000));
    await tester.pumpAndSettle();

    const texts = [
      'ACADEMIC',
      'My Courses',
      '5 enrolled this semester',
      'ACCOUNT',
      'Personal Information',
      'Notification Preferences',
      'Change Password',
      'APP',
      'Settings',
      'Help',
      'About',
      ProfileDemoData.appVersionLabel,
      'Logout',
      ProfileDemoData.footerVersionLabel,
    ];
    for (final text in texts) {
      expect(find.text(text).hitTestable(), findsOneWidget, reason: text);
    }
    expect(find.text('Profile').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home and Profile switch tabs without pushing routes', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, tab: AppDestination.home);
    expect(_selectedTab(tester), AppDestination.home);
    expect(find.byType(ProfileScreen), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), AppDestination.profile);
    expect(find.text('My Profile').hitTestable(), findsOneWidget);
    final nav = find.byType(AppBottomNavigation);
    expect(nav, findsOneWidget);
    expect(
      tester.getSemantics(
        find.descendant(of: nav, matching: find.text('Profile')),
      ),
      isSemantics(isSelected: true, isButton: true),
    );
    expect(
      tester.getSemantics(
        find.descendant(of: nav, matching: find.text('Home')),
      ),
      isSemantics(isSelected: false, isButton: true),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(navigator.canPop(), isFalse);

    await tester.tap(find.text('Schedule'));
    await tester.pump();
    expect(
      find.text(HomeScreen.notImplementedMessage('Schedule')),
      findsOneWidget,
    );
    expect(_selectedTab(tester), AppDestination.profile);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), AppDestination.home);
    expect(find.text('My Profile').hitTestable(), findsNothing);
    expect(navigator.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile keeps its scroll position while on another tab', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);
    await tester.drag(_profileScrollable(), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('Logout').hitTestable(), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Logout').hitTestable(), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Logout').hitTestable(), findsOneWidget);
    expect(find.text('My Profile').hitTestable(), findsNothing);
  });

  testWidgets('Placeholder actions show their messages and stay on Profile', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);

    await _tapExpectingMessage(
      tester,
      find.bySemanticsLabel('Settings'),
      ProfileScreen.messageFor(ProfileAction.settings),
    );
    await _tapExpectingMessage(
      tester,
      find.text('Edit Profile'),
      ProfileScreen.messageFor(ProfileAction.editProfile),
    );
    for (final item in [
      ...ProfileDemoData.academicMenu,
      ...ProfileDemoData.accountMenu,
      ...ProfileDemoData.appMenu,
    ]) {
      await _tapExpectingMessage(
        tester,
        find.text(item.title),
        ProfileScreen.messageFor(item.action),
      );
    }

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(_selectedTab(tester), AppDestination.profile);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('Logout fires the controller callback exactly once', (
    WidgetTester tester,
  ) async {
    final probe = await _pumpShell(tester);
    await _scrollTo(tester, find.text('Logout'));

    await tester.tap(find.text('Logout'));
    await tester.pump();
    // A duplicate tap during the transition must not fire again.
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(probe.calls, 1);
  });

  testWidgets('Profile does not overflow on a small device with large text', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpShell(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);

    await _scrollTo(tester, find.text(ProfileDemoData.footerVersionLabel));
    expect(tester.takeException(), isNull);
  });
}
