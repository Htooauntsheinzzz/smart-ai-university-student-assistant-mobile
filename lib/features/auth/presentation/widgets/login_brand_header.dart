import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../splash/presentation/screens/splash_screen.dart';

/// Logo, "SMART • AI" label and app title above the login card.
///
/// The logo asset already contains the Thai and English university names, so
/// they are not repeated as text.
class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key});

  /// Figma logo width; the height (≈235.5) follows from the asset's ratio.
  static const double logoWidth = 210;

  /// How far the logo sits to the right of the header's centre line; asked
  /// for by the product owner after seeing the screen (DEC-007).
  static const double logoShiftRight = 12;

  /// Distance from the top of the frame to the logo in Figma.
  static const double _referenceTopInset = 58;

  @override
  Widget build(BuildContext context) {
    // The Figma inset is measured from the top of the frame and already
    // clears the status bar there, so it doubles as the safe-area inset:
    // use whichever is larger instead of adding them.
    final topInset = math.max(
      _referenceTopInset,
      MediaQuery.viewPaddingOf(context).top,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(4, topInset, 4, AppSpacing.lg),
      child: Column(
        children: [
          // Left padding of twice the shift moves the centred image right by
          // the shift itself.
          Padding(
            padding: const EdgeInsets.only(left: logoShiftRight * 2),
            child: Semantics(
              image: true,
              label: 'Rangsit University logo',
              child: Image.asset(
                SplashScreen.logoAsset,
                width: logoWidth,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Semantics(
            label: 'SMART • AI',
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(
                children: const [
                  TextSpan(text: 'SMART '),
                  TextSpan(
                    text: '•',
                    style: TextStyle(color: AppColors.brandDot),
                  ),
                  TextSpan(text: ' AI'),
                ],
                style: AppFonts.interStyle(
                  size: 10,
                  weight: FontWeight.w700,
                  letterSpacing: 2.4,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'University Student Assistant',
            textAlign: TextAlign.center,
            style: AppFonts.poppinsBold(
              size: 21,
              color: AppColors.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
