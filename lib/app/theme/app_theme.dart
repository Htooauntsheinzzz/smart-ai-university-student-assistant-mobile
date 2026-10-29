import 'package:flutter/material.dart';

/// Central colour tokens for the application.
///
/// The background colour was supplied by the product owner (`#273238`); the
/// remaining splash colours are derived from it and the design screenshot.
/// Replace with exact Figma tokens once the design file is accessible.
abstract final class AppColors {
  /// Dark slate page background used by the loading screen.
  static const Color background = Color(0xFF273238);

  /// Slightly lighter surface on the background (progress-bar track).
  static const Color surface = Color(0xFF3A4852);

  /// Primary accent (links, indicator fill, "SMART • AI" label).
  static const Color skyBlue = Color(0xFF4DA3FF);

  /// Main text on the background.
  static const Color onBackground = Colors.white;

  /// Secondary text on the background.
  static const Color onBackgroundMuted = Color(0xFFB8C2CA);

  /// Rule lines beside the subtitle and inactive dots.
  static const Color rule = Color(0xFF4A5862);

  // Login screen tokens, from the inspected Figma frame `Login Screen` (5:2)
  // as listed in `spec-md/02-logiin-screen.md`.

  /// Login card background.
  static const Color card = Colors.white;

  /// Primary text on light surfaces (same value as [background]).
  static const Color textPrimary = Color(0xFF273238);

  /// Secondary text on light surfaces.
  static const Color textSecondary = Color(0xFF66788A);

  /// Text field background.
  static const Color fieldBackground = Color(0xFFF8FAFC);

  /// Card and text field borders.
  static const Color fieldBorder = Color(0xFFDFE5EB);

  /// Placeholder text and icons inside fields.
  static const Color placeholder = Color(0xFFAAB6C2);

  /// Disabled button background.
  static const Color buttonDisabled = Color(0xFFEEF3F7);

  /// Disabled button text (same value as [placeholder]).
  static const Color onButtonDisabled = Color(0xFFAAB6C2);

  /// Unchecked checkbox border.
  static const Color checkboxBorder = Color(0xFFCAD3DC);

  /// Footer text on the dark background.
  static const Color footer = Color(0xFFAEB8C2);

  /// Pink separator dot in the "SMART • AI" label.
  static const Color brandDot = Color(0xFFD80255);

  /// Field and form error colour (not in the inspected frame, DEC-005).
  static const Color error = Color(0xFFD93B3B);

  // Home screen tokens, from the inspected Figma frame `Home Page Screen`
  // (3:209) as listed in `spec-md/03-home-page-screen.md`. Primary/secondary
  // text, borders and the pink accent reuse [textPrimary], [textSecondary],
  // [fieldBorder] and [brandDot].

  /// Light page background behind the home cards.
  static const Color pageBackground = Color(0xFFF3F6FA);

  /// Student avatar background and dark-card border.
  static const Color avatar = Color(0xFF34434B);

  /// Muted text and inactive bottom-navigation items.
  static const Color textMuted = Color(0xFF8797A8);

  /// Light dividers between list rows.
  static const Color divider = Color(0xFFEEF3F7);

  /// Read-announcement dot and chevrons.
  static const Color inactiveDot = Color(0xFFCAD3DC);

  /// Blue accent (course codes, AI label, links).
  static const Color accentBlue = Color(0xFF01A2E5);

  /// Light blue tint behind blue badges.
  static const Color accentBlueLight = Color(0xFFE8F5FC);

  /// Background of the next-class time panel.
  static const Color timePanel = Color(0xFFF2F8FC);

  /// Online / status green.
  static const Color success = Color(0xFF16A34A);

  /// Urgent red (due today).
  static const Color urgent = Color(0xFFDC2626);

  /// Light red tint behind urgent icons and badges.
  static const Color urgentLight = Color(0xFFFEF2F2);

  /// Amber accent strip.
  static const Color amber = Color(0xFFF59E0B);

  /// Amber text.
  static const Color amberText = Color(0xFFD97706);

  /// Light amber tint behind amber icons and badges.
  static const Color amberLight = Color(0xFFFEF3C7);

  // Profile screen tokens, from the inspected Figma frame `Profile Screen`
  // (28:30) as listed in `spec-md/04-profile-screen.md`. The dark header, page
  // background, text, blue/green/pink/amber accents and the logout red reuse
  // the tokens above.

  /// Border of the white profile cards.
  static const Color cardBorder = Color(0xFFE2E8EE);

  /// Purple accent (Personal Information menu icon).
  static const Color accentPurple = Color(0xFF8B5CF6);

  /// Faint red border of the Logout button.
  static const Color logoutBorder = Color(0x21FCA5A5);

  /// Faint text such as the version footer (same value as [placeholder]).
  static const Color textFaint = Color(0xFFAAB6C2);

  // AI chat screen tokens, from the inspected Figma frame `Ai-Chat Screen`
  // (33:30) as listed in `spec-md/05-ai-chat-screen.md`. The dark header, page
  // background, text, borders, blue accent and status green reuse the tokens
  // above; the disabled Send background is [fieldBorder].

  /// Suggested-prompt chip text.
  static const Color textPrompt = Color(0xFF44545F);
}

/// Shadow tokens from the Figma home frame.
abstract final class AppShadows {
  /// Light cards (next class, deadlines, announcements).
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A273238), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0D273238), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Smaller raised elements (quick-action tiles, avatar, white buttons).
  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x0A273238), blurRadius: 1, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0D273238), blurRadius: 6, offset: Offset(0, 4)),
  ];

  /// Dark AI card.
  static const List<BoxShadow> darkCard = [
    BoxShadow(color: Color(0x33273238), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x33273238), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Dark filled button (Navigate).
  static const List<BoxShadow> darkButton = [
    BoxShadow(color: Color(0x33273238), blurRadius: 1, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x33273238), blurRadius: 6, offset: Offset(0, 4)),
  ];

  /// Blue assistant avatar in the chat ([raised] geometry, blue tinted).
  static const List<BoxShadow> blueRaised = [
    BoxShadow(color: Color(0x3301A2E5), blurRadius: 1, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x3301A2E5), blurRadius: 6, offset: Offset(0, 4)),
  ];
}

/// Bundled font families (see `pubspec.yaml`).
abstract final class AppFonts {
  /// Poppins (Bold and Black faces), used for titles.
  static const String poppins = 'Poppins';

  /// Inter variable font, used for labels, inputs, buttons and footers.
  static const String inter = 'Inter';

  /// Inter at [size] and [weight].
  ///
  /// Inter is bundled as a variable font, so the weight is also set on the
  /// `wght` axis; that renders the right weight on every platform instead of
  /// relying on synthetic bolding.
  static TextStyle interStyle({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: inter,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Poppins Bold at [size].
  static TextStyle poppinsBold({
    required double size,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      height: height,
    );
  }

  /// Poppins Black at [size] (profile heading, avatar initial and name).
  static TextStyle poppinsBlack({
    required double size,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: size,
      fontWeight: FontWeight.w900,
      color: color,
      height: height,
    );
  }
}

/// Spacing scale shared across screens.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Builds the application's Material 3 theme.
abstract final class AppTheme {
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.skyBlue,
      brightness: Brightness.dark,
      surface: AppColors.background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.skyBlue,
        linearTrackColor: AppColors.surface,
      ),
    );
  }
}
