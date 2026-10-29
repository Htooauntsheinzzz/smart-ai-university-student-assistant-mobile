import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_ai_university_student_assistant/app/app.dart';
import 'package:smart_ai_university_student_assistant/core/network/api_exception.dart';
import 'package:smart_ai_university_student_assistant/core/storage/session_storage.dart';
import 'package:smart_ai_university_student_assistant/features/assistant/presentation/screens/ai_chat_screen.dart';
import 'package:smart_ai_university_student_assistant/features/assistant/presentation/widgets/chat_message_bubble.dart';
import 'package:smart_ai_university_student_assistant/features/auth/data/token_store.dart';
import 'package:smart_ai_university_student_assistant/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_ai_university_student_assistant/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_ai_university_student_assistant/features/auth/presentation/widgets/login_form.dart';
import 'package:smart_ai_university_student_assistant/features/home/presentation/screens/home_screen.dart';
import 'package:smart_ai_university_student_assistant/features/profile/presentation/screens/profile_screen.dart';
import 'package:smart_ai_university_student_assistant/features/splash/presentation/screens/splash_screen.dart';

import 'support/auth_fakes.dart';

// The login screen only has one FilledButton, so byType matches it in
// both the enabled and submitting states (its child becomes a spinner
// while a request is in flight, so widgetWithText doesn't find it).
Finder _signInButton() => find.descendant(
  of: find.byType(LoginForm),
  matching: find.byType(FilledButton),
);

/// Builds a fresh [App] with a controller backed by [api] (and
/// optional [storage]) at the Figma reference size.
Future<AuthController> _pumpApp(
  WidgetTester tester, {
  required FakeAuthApi api,
  InMemorySessionStorage? storage,
  bool referenceSize = true,
}) async {
  if (referenceSize) {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }
  final controller = AuthController(
    api: api,
    sessionStorage: storage ?? InMemorySessionStorage(),
    tokenStore: TokenStore(),
  );
  await tester.pumpWidget(App(authController: controller));
  // Give the post-frame callback a tick for restore() to run, then let
  // any pending microtasks settle. Avoid pumpAndSettle here: the splash
  // loader animation repeats forever while status is still initializing,
  // which would deadlock pumpAndSettle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return controller;
}

/// Enters valid-looking credentials, taps Sign In and settles.
Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).first, 'student@rsu.ac.th');
  await tester.enterText(find.byType(TextField).last, 'P@ssw0rd');
  await tester.pump();
  await tester.tap(_signInButton());
  await tester.pumpAndSettle();
}

Future<void> _logout(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Logout'),
    300,
    scrollable: find.descendant(
      of: find.byType(ProfileScreen),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.tap(find.text('Logout'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('With no stored session the app lands on the login screen after '
      'the splash', (WidgetTester tester) async {
    final api = FakeAuthApi();
    await _pumpApp(tester, api: api);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('Welcome back'), findsOneWidget);
    // No stored token, so refresh must never run.
    expect(api.refreshCalls, isEmpty);
  });

  testWidgets('A persisted session is restored directly to Home', (
    WidgetTester tester,
  ) async {
    final api = FakeAuthApi()..queueRefreshSuccess(buildSession());
    final storage = InMemorySessionStorage()
      ..writeRefreshToken('persisted-token');

    await _pumpApp(tester, api: api, storage: storage);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(api.refreshCalls.single.refreshToken, 'persisted-token');
  });

  testWidgets('A restoration network failure shows Try Again on the splash and '
      'retrying lands on Home', (WidgetTester tester) async {
    final api = FakeAuthApi()
      ..queueRefreshError(TestApiErrors.noConnection())
      ..queueRefreshSuccess(buildSession());
    final storage = InMemorySessionStorage()
      ..writeRefreshToken('persisted-token');

    await _pumpApp(tester, api: api, storage: storage);

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text(AuthMessages.noConnection), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Try Again'), findsOneWidget);
    // Persisted token must survive a temporary network outage.
    expect(await storage.readRefreshToken(), 'persisted-token');

    await tester.tap(find.widgetWithText(FilledButton, 'Try Again'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Login validates before calling the backend', (
    WidgetTester tester,
  ) async {
    final api = FakeAuthApi();
    await _pumpApp(tester, api: api);

    // Sign In is disabled while the form is empty.
    expect(tester.widget<FilledButton>(_signInButton()).onPressed, isNull);

    final form = tester.state<FormState>(find.byType(Form));
    form.validate();
    await tester.pump();
    expect(find.text('Enter your student email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(api.loginCalls, isEmpty);
  });

  testWidgets(
    'Invalid credentials show the mapped message and keep the typed email',
    (WidgetTester tester) async {
      final api = FakeAuthApi()
        ..queueLoginError(TestApiErrors.invalidCredentials());
      await _pumpApp(tester, api: api);

      await tester.enterText(find.byType(TextField).first, '6708457@rsu.ac.th');
      await tester.enterText(find.byType(TextField).last, 'wrong');
      await tester.pump();
      await tester.tap(_signInButton());
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text(AuthMessages.invalidCredentials), findsOneWidget);
      // Email is preserved so the user does not retype it.
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '6708457@rsu.ac.th',
      );
    },
  );

  testWidgets(
    'A duplicate Sign In tap during submission does not fire a second request',
    (WidgetTester tester) async {
      final api = FakeAuthApi();
      // Hold the login response open with a Completer so submission
      // state is observable in the middle of the test.
      final gate = Completer<void>();
      api.queueLoginFuture(gate.future.then((_) => buildSession()));

      await _pumpApp(tester, api: api);
      await tester.enterText(find.byType(TextField).first, 'a@rsu.ac.th');
      await tester.enterText(find.byType(TextField).last, 'secret');
      await tester.pump();
      await tester.tap(_signInButton());
      await tester.pump();
      // The button is now disabled (spinner); the finder still matches
      // the FilledButton but its onPressed is null.
      final buttonFinder = _signInButton();
      expect(buttonFinder, findsOneWidget);
      expect(tester.widget<FilledButton>(buttonFinder).onPressed, isNull);
      // Try tapping anyway: should be ignored.
      await tester.tap(buttonFinder, warnIfMissed: false);
      await tester.pump();
      expect(api.loginCalls, hasLength(1));

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(api.loginCalls, hasLength(1));
    },
  );

  testWidgets(
    'Logout clears the session, chat and persisted token, and returns to Login',
    (WidgetTester tester) async {
      final api = FakeAuthApi()
        ..queueLoginSuccess(buildSession())
        ..queueLogoutSuccess()
        ..queueLoginSuccess(
          buildSession(accessToken: 'access-2', refreshToken: 'refresh-2'),
        );
      final storage = InMemorySessionStorage();
      await _pumpApp(tester, api: api, storage: storage);

      // Sign in with Keep Me Signed In so a refresh token gets persisted.
      await tester.tap(find.text('Keep me signed in'));
      await _signIn(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(await storage.readRefreshToken(), 'refresh-token-1');

      // Add a draft to the chat so logout has something to clear.
      await tester.tap(find.text('AI Chat'));
      await tester.pumpAndSettle();
      expect(find.byType(AiChatScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send message'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatMessageBubble), findsNWidgets(2));
      await tester.enterText(find.byType(TextField), 'Draft');
      await tester.pump();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await _logout(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(AiChatScreen), findsNothing);
      expect(api.logoutCalls, hasLength(1));
      expect(await storage.readRefreshToken(), isNull);

      // Signing in again brings up a fresh chat, not the previous one.
      await _signIn(tester);
      await tester.tap(find.text('AI Chat'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatMessageBubble), findsOneWidget);
      expect(find.text('Hello'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    },
  );

  testWidgets('Forgot Password shows the temporary message', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, api: FakeAuthApi());

    await tester.tap(find.text('Forgot Password?'));
    await tester.pump();
    expect(find.text(LoginForm.resetUnavailableMessage), findsOneWidget);
  });
}
