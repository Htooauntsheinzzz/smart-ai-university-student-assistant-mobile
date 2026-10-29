import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/app_bottom_navigation.dart';
import '../../features/assistant/presentation/controllers/demo_chat_controller.dart';
import '../../features/assistant/presentation/screens/ai_chat_screen.dart';
import '../../features/assistant/presentation/widgets/chat_composer.dart';
import '../../features/auth/data/models/student_user.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../theme/app_theme.dart';

/// Signed-in area of the app: one [Scaffold] with the shared
/// [AppBottomNavigation] and the tab screens stacked in its body.
///
/// Switching tabs changes which screen is shown instead of pushing routes, so
/// repeated taps never stack copies, every opened tab keeps its scroll
/// position, and a single navigation bar serves all tabs (DEC-008). The shell
/// also owns the demo chat conversation, so it survives tab switches and is
/// dropped with the shell on logout, and places the chat composer in the
/// Scaffold's bottom slot above the bar while AI Chat is selected (DEC-009).
/// Tabs without a screen yet show a short "not implemented yet" message and
/// leave the selection unchanged (DEC-006).
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.student,
    required this.onLogout,
    this.initialDestination = AppDestination.home,
  });

  /// Authenticated student used by Home and Profile for identity fields
  /// (DEC-010).
  final StudentUser student;

  /// Called when the Profile Logout action is confirmed. The real
  /// implementation revokes the backend session, clears every local
  /// token and flips [AuthController] to unauthenticated, which drops
  /// this shell from the widget tree.
  final Future<void> Function() onLogout;

  /// Tab shown first; must be one of [tabs].
  final AppDestination initialDestination;

  /// Destinations that have a screen, in stacking order.
  static const List<AppDestination> tabs = [
    AppDestination.home,
    AppDestination.aiChat,
    AppDestination.profile,
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppDestination _selected = widget.initialDestination;

  /// Tabs built so far; the others stay empty until first opened.
  final Set<AppDestination> _opened = {};

  /// Local demo conversation, composer draft and focus (DEC-009).
  final DemoChatController _chat = DemoChatController();

  @override
  void initState() {
    super.initState();
    assert(
      AppShell.tabs.contains(widget.initialDestination),
      'No screen exists for ${widget.initialDestination} yet.',
    );
    _opened.add(widget.initialDestination);
  }

  @override
  void dispose() {
    _chat.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows [destination], which must be one of [AppShell.tabs].
  void _select(AppDestination destination) {
    if (destination == _selected) return;
    // The keyboard belongs to the tab being left (the chat composer).
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _selected = destination;
      _opened.add(destination);
    });
  }

  void _onSelected(AppDestination destination) {
    if (!AppShell.tabs.contains(destination)) {
      _showMessage(HomeScreen.notImplementedMessage(destination.label));
      return;
    }
    _select(destination);
  }

  /// Opens AI Chat with [prompt] in the composer, unless a different draft
  /// is already there; nothing is sent.
  void _askAssistant(String prompt) {
    _select(AppDestination.aiChat);
    if (!_chat.prefill(prompt)) _showMessage(AiChatScreen.draftInUseMessage);
  }

  Widget _screen(AppDestination destination) => switch (destination) {
    AppDestination.home => HomeScreen(
      student: widget.student,
      onOpenAssistant: () => _select(AppDestination.aiChat),
      onAskAssistant: _askAssistant,
    ),
    AppDestination.aiChat => AiChatScreen(controller: _chat),
    AppDestination.profile => ProfileScreen(
      student: widget.student,
      onLogout: widget.onLogout,
    ),
    _ => throw StateError('No screen exists for $destination yet.'),
  };

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        bottomNavigationBar: _BottomArea(
          footer: _selected == AppDestination.aiChat
              ? ChatComposer(controller: _chat)
              : null,
          navigation: AppBottomNavigation(
            selected: _selected,
            onSelected: _onSelected,
          ),
        ),
        body: Stack(
          children: [
            IndexedStack(
              index: AppShell.tabs.indexOf(_selected),
              children: [
                for (final tab in AppShell.tabs)
                  _opened.contains(tab)
                      ? _screen(tab)
                      : const SizedBox.shrink(),
              ],
            ),
            // Each tab's dark header scrolls away with its page; keep the
            // status bar on the header colour so its light icons stay readable.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset,
              child: const ColoredBox(color: AppColors.background),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom slot of the shell: the selected tab's [footer] (the chat composer)
/// above the [navigation] bar.
///
/// Being in the Scaffold's bottom slot, both sit below the body, so SnackBars
/// appear above the footer instead of covering it. While the keyboard is
/// open the bar's slot grows to the keyboard height: the footer rises with
/// the keyboard, the bar stays hidden behind it, and the body shrinks once
/// instead of being inset twice (DEC-009).
class _BottomArea extends StatelessWidget {
  const _BottomArea({required this.footer, required this.navigation});

  final Widget? footer;
  final Widget navigation;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?footer,
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: keyboard),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [navigation],
          ),
        ),
      ],
    );
  }
}
