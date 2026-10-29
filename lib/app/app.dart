import 'package:flutter/material.dart';

import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import 'theme/app_theme.dart';

/// Root widget of the application.
///
/// Instantiates once at startup and hands the auth state to [AuthGate],
/// which swaps between the splash, login and signed-in shell as the
/// state changes (DEC-010). There are no named routes: logout and
/// successful login simply flip the state and the gate rebuilds the
/// correct screen.
class App extends StatefulWidget {
  const App({super.key, required this.authController});

  final AuthController authController;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    // Kick off session restoration on first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authController.restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart AI University Student Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AuthGate(controller: widget.authController),
    );
  }
}
