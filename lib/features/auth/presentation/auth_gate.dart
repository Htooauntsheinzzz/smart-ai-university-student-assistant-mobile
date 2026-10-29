import 'package:flutter/material.dart';

import '../../../app/shell/app_shell.dart';
import '../../splash/presentation/screens/splash_screen.dart';
import 'controllers/auth_controller.dart';
import 'screens/login_screen.dart';

/// Decides which top-level screen to show based on [AuthController]
/// status (DEC-010). Rebuilt whenever the controller notifies.
///
/// - `initializing` or `initializationError` → splash (session restore
///   is in flight, or offered as retry on a temporary failure).
/// - `unauthenticated` or `submitting` → login screen.
/// - `authenticated` → signed-in shell on Home, with the backend
///   student handed down.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        switch (controller.status) {
          case AuthStatus.initializing:
            return const SplashScreen();
          case AuthStatus.initializationError:
            return SplashScreen(
              errorMessage: controller.errorMessage,
              onRetry: controller.retryInitialization,
            );
          case AuthStatus.unauthenticated:
          case AuthStatus.submitting:
            return LoginScreen(controller: controller);
          case AuthStatus.authenticated:
            final user = controller.user!;
            return AppShell(student: user, onLogout: controller.logout);
        }
      },
    );
  }
}
