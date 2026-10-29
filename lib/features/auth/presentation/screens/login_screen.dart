import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_brand_header.dart';
import '../widgets/login_footer.dart';
import '../widgets/login_form.dart';

/// Login screen from the Figma frame `Login Screen` (node `5:2`).
///
/// Layout (top to bottom, scrollable): branding header on the dark
/// background, the white login card and the copyright footer. The form
/// is driven by [AuthController]; the design is unchanged (DEC-010).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.controller});

  final AuthController controller;

  /// Horizontal margin between the screen edge and the card.
  static const double _cardMargin = 16;

  /// Widest the content grows on tablets (Figma card width is 370).
  static const double _maxContentWidth = 440;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          // The brand header applies the top inset itself (see
          // LoginBrandHeader) and the bottom padding below accounts for the
          // home indicator, so SafeArea only handles the sides.
          child: SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                _cardMargin,
                0,
                _cardMargin,
                // As in Figma, the footer may sit beside the home indicator
                // but never under it.
                math.max(
                  AppSpacing.md,
                  MediaQuery.viewPaddingOf(context).bottom - AppSpacing.md,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LoginBrandHeader(),
                      LoginForm(controller: controller),
                      const SizedBox(height: AppSpacing.lg),
                      const LoginFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
