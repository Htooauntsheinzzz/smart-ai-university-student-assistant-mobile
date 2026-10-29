# Changes and Decision Log

### DEC-001 — Initial loading / splash screen

- **Date:** 2026-10-25
- **Status:** Implemented
- **Module:** `features/splash`, `app/` (app shell and theme)
- **Context:** `spec-md/01-loading-screen.md` asks for the Flutter splash screen shown after the native launch screen, using the Rangsit University logo and the Figma loading-screen frame.
- **Decision:** Replace the Flutter counter starter with a minimal app shell (`App` + `AppTheme`) whose initial route is `SplashScreen`. The screen is built from the user-supplied screenshot of the design: dark navy background, logo on a white rounded card, "SMART • AI" label, "University Student Assistant" title, "Your Smart Campus Companion" with side rules, "RANGSIT UNIVERSITY", an indeterminate progress bar, three dots, and "Loading your campus experience..." at the bottom.
- **Reason:** The Figma file (`RUhIF3MsPa9jTWfT0Dou02`, node `0:1`) could not be opened: the Figma MCP server requires an OAuth sign-in that has not been granted, and the web link requires a Figma login. Per the spec, the supplied screenshot was used instead of inventing details. Exact colour hex values, font sizes and spacing are therefore approximations from the screenshot, centralised in `AppColors`/`AppSpacing` so they can be swapped for Figma tokens later. No loading-screen node ID could be recorded.
- **Changes:**
  - New `lib/app/app.dart` (`MaterialApp` with `home: SplashScreen()`), `lib/app/theme/app_theme.dart` (colour, spacing and Material 3 theme tokens).
  - `lib/main.dart` reduced to `runApp(const App())`.
  - New `lib/features/splash/presentation/screens/splash_screen.dart`.
  - Logo: `assets/images/rangsitlogo.png` (already declared in `pubspec.yaml`) rendered with `Image.asset` + `BoxFit.contain`. The PNG is 1000×1000 with the artwork in the central ~25 % and transparent elsewhere, so it is drawn on a white card with `Transform.scale(3.2)`; only transparent padding is clipped, the artwork keeps its aspect ratio and is not cropped or tinted.
  - Layout uses `SafeArea` + `CustomScrollView`/`SliverFillRemaining` so it centres on tall screens and scrolls instead of overflowing on small screens or with large text scaling.
  - Progress bar is an indeterminate `LinearProgressIndicator`; no percentages are shown. The three dots are static (design shows a static frame; no animation requested).
  - Starter test replaced by `test/widget_test.dart` (initial screen, logo asset/fit, small-device overflow check).
- **Affected files:** `lib/main.dart`, `lib/app/app.dart`, `lib/app/theme/app_theme.dart`, `lib/features/splash/presentation/screens/splash_screen.dart`, `test/widget_test.dart`, `spec-md/00-changes-and-decisions.md`
- **Validation:** `dart format .` (clean), `flutter analyze` (no issues), `flutter test` (2 passed). Ran on the iPhone 17 Pro simulator (iOS 27): screen renders as designed, logo loads with correct aspect ratio, subtitle stays on one line, no overflow. Android not verified.
- **Follow-up:**
  - Automatic navigation is pending: no startup/session initialisation or router exists yet, so the splash screen stays on screen (preview-only). Wire it to `go_router` and the session-restore flow when auth is implemented (DEC-00x).
  - `go_router` / `flutter_riverpod` from `Agent.md` were not added, since the spec forbids adding packages solely for this screen.
  - Re-check colours, type sizes and spacing against the real Figma frame once design access is granted, and record the node ID.

### DEC-002 — Splash background `#273238` and logo without a card

- **Date:** 2026-10-25
- **Status:** Implemented
- **Module:** `features/splash`, `app/theme`
- **Context:** After reviewing DEC-001 on the simulator, the product owner asked for the splash background to be `#273238` and for the logo to be shown transparent on that background (no white card behind it).
- **Decision:** Set `AppColors.background` to `#273238` and derive the secondary splash colours from it (`surface` `#3A4852` for the progress track, `rule` `#4A5862`, `onBackgroundMuted` `#B8C2CA`); render `assets/images/rangsitlogo.png` directly on the background with its own transparency, dropping the white rounded card and shadow. Supersedes the navy background and logo card from DEC-001.
- **Reason:** Direct request from the product owner. The logo PNG already has a transparent background, so no asset change was needed.
- **Changes:**
  - `AppColors` tokens renamed from navy-specific names (`navy`, `navyLight`, `onNavy`, `onNavyMuted`) to neutral ones (`background`, `surface`, `onBackground`, `onBackgroundMuted`) and re-valued.
  - `_LogoCard` replaced by `_Logo`: a 170 dp `SizedBox` + `ClipRect` + `Transform.scale(3.2)` around `Image.asset(..., fit: BoxFit.contain)`. As before, only transparent padding is clipped; the artwork keeps its aspect ratio and is not cropped or tinted.
- **Affected files:** `lib/app/theme/app_theme.dart`, `lib/features/splash/presentation/screens/splash_screen.dart`
- **Validation:** `dart format .` (clean), `flutter analyze` (no issues), `flutter test` (2 passed). Ran on the iPhone 17 Pro simulator (iOS 27): background and transparent logo render as requested. Android not verified.
- **Follow-up:** The logo's dark grey Thai wordmark and "RANGSIT UNIVERSITY" text inside the PNG have very low contrast on `#273238` (the flame and sunburst read fine). Raised with the product owner; options are to keep as is, obtain a light/white-on-transparent logo variant from the university, or add a light backing shape. Cropping the wordmark out of the asset is not done, per the spec's no-cropping rule, unless the owner approves it.

### DEC-003 — New Figma logo export replaces the original logo asset

- **Date:** 2026-10-25
- **Status:** Implemented
- **Module:** `features/splash`, assets
- **Context:** Following DEC-002, the product owner exported the logo from the Figma design and replaced `assets/images/rangsitlogo.png` with it, then asked for the splash screen to be re-implemented with the new asset. The Figma file itself is still inaccessible (connector not signed in, web link behind login), so the layout from DEC-001/DEC-002 is kept.
- **Decision:** Show the new asset as-is: `Image.asset` at a fixed 180 dp width with `BoxFit.contain`, height following the image's own aspect ratio. The `ClipRect` + `Transform.scale` workaround from DEC-002 is removed because the new export has no large transparent margin.
- **Reason:** The new PNG is 1480×1660 RGBA with the artwork filling ~90 % × 95 % of the canvas and a white Thai/English wordmark, so it reads correctly on `#273238` without any card, scaling or clipping. This also closes the low-contrast follow-up raised in DEC-002.
- **Changes:**
  - `assets/images/rangsitlogo.png` replaced by the product owner (same path, so `pubspec.yaml` is unchanged).
  - `_Logo` in `splash_screen.dart` simplified to a plain `Image.asset(width: 180, fit: BoxFit.contain)`.
- **Affected files:** `assets/images/rangsitlogo.png`, `lib/features/splash/presentation/screens/splash_screen.dart`
- **Validation:** `dart format .` (clean), `flutter analyze` (no issues), `flutter test` (2 passed). Ran on the iPhone 17 Pro simulator (iOS 27): the full logo renders with its aspect ratio preserved, the wordmark is legible, no overflow. Android not verified.
- **Follow-up:** Exact Figma colours, typography and spacing for node `5:186` remain unverified until the Figma connector is signed in or the frame is shared; the logo's built-in "RANGSIT UNIVERSITY" wordmark now appears above the separate "RANGSIT UNIVERSITY" label, which may be worth removing if the Figma frame does not have both.

### DEC-004 — Native launch screens match the Flutter splash (Android + iOS)

- **Date:** 2026-10-25
- **Status:** Implemented
- **Module:** Android launch theme / Android 12+ system splash, iOS LaunchScreen
- **Context:** Running on a Pixel 10 Pro emulator, the product owner saw the stock Flutter launch screen (white background with the Flutter launcher icon) before the Flutter splash screen and asked for the app to start on the loading screen. On Android 12+ the OS always shows a system splash (background + icon) before the app window exists, and iOS always shows the launch storyboard, so the only way to get there is to make those native screens look like the Flutter splash.
- **Decision:** Deviation from `01-loading-screen.md` ("Do not implement native Android/iOS launch-screen customization"), made at the product owner's explicit request in the thread. Both native launch screens now use `#273238` with the university logo centred, matching `AppColors.background` and the 180 dp logo width of the Flutter splash.
- **Reason:** The stock white screen with the Flutter logo is what the owner saw first and did not want; a native screen that matches the Flutter splash makes the start look like one continuous loading screen. The launcher icon itself (`mipmap/ic_launcher`, still Flutter's default) is out of scope here.
- **Changes:**
  - Android: new `values/colors.xml` (`splash_background`), `LaunchTheme`/`NormalTheme` window backgrounds set to that colour, `drawable/launch_background.xml` and `drawable-v21/launch_background.xml` draw the colour plus a centred `splash_logo` bitmap, density PNGs `drawable-{m,h,xh,xxh,xxxh}dpi/splash_logo.png` generated from `assets/images/rangsitlogo.png` at 180 dp wide. New `values-v31/styles.xml` and `values-night-v31/styles.xml` set `windowSplashScreenBackground` and `windowSplashScreenAnimatedIcon` (the night variant is needed because the `-night` qualifier outranks `-v31`). `drawable/splash_icon.xml` is an `<inset>` with percentage insets so the logo stays inside the circular mask the system applies to the splash icon (the first attempt with absolute dp sizes, and a one-frame animation-list meant to bypass the mask, were both still clipped on API 36 and were discarded).
  - iOS: `LaunchScreen.storyboard` background set to `#273238`; `LaunchImage.imageset` PNGs replaced by the logo at 180×202 pt (1x/2x/3x).
- **Affected files:** `android/app/src/main/res/values/colors.xml`, `android/app/src/main/res/values/styles.xml`, `android/app/src/main/res/values-night/styles.xml`, `android/app/src/main/res/values-v31/styles.xml`, `android/app/src/main/res/values-night-v31/styles.xml`, `android/app/src/main/res/drawable/launch_background.xml`, `android/app/src/main/res/drawable-v21/launch_background.xml`, `android/app/src/main/res/drawable/splash_icon.xml`, `android/app/src/main/res/drawable-*dpi/splash_logo.png`, `ios/Runner/Base.lproj/LaunchScreen.storyboard`, `ios/Runner/Assets.xcassets/LaunchImage.imageset/*.png`
- **Validation:** `flutter build apk --debug` and `flutter build ios --simulator --debug` succeed. Android: cold start captured on an API 36 emulator (1080×1920, 420 dpi) at 0.3 s, 0.5 s, 2 s and 5 s: dark background with the full, unclipped logo on the system splash, then the Flutter splash, no white frame. An earlier capture on the owner's Pixel 10 Pro emulator (API 37) confirmed the dark splash and the seamless hand-off before the icon sizing fix. iOS: cold launch captured on the iPhone 17 Pro simulator at 0.2 s, 0.5 s, 1 s and 3 s: dark launch screen, logo, then the Flutter splash. Physical devices not tested.
- **Follow-up:** The home-screen app icon is still the Flutter default; replacing it needs an icon set (or `flutter_launcher_icons`) and the owner's artwork. On Android 12+ the system splash icon is necessarily smaller than the Flutter splash logo because of the OS mask; the logo then grows when the Flutter frame appears.

### DEC-005 — Login screen and splash-to-login navigation

- **Date:** 2026-10-26
- **Status:** Implemented
- **Module:** `features/auth`, `features/splash`, `app/` (routes, theme, fonts)
- **Context:** `spec-md/02-logiin-screen.md` asks for the login screen from the Figma frame `Login Screen` (node `5:2`, 402 × 874) and for the existing loading screen to hand off to it once its progress bar finishes. UI and local form behaviour only; no authentication API.
- **Decision:** Build the login screen from the spec's design tokens, typography table and layout measurements plus the supplied screenshot of the frame, bundle the two fonts the design uses, give the app plain named routes (`/` splash, `/login`), and make the splash progress bar a fixed 2.5 s timer whose completion replaces the splash route with login. The Figma MCP connector is still not signed in and the web link is behind a Figma login, so the frame itself was not inspected; the spec tokens are treated as the inspected values.
- **Reason:** The spec allows building from its measurements when the frame cannot be inspected, and the measurements, colours and type styles are listed in full. The splash screen had no completion signal (DEC-001 left navigation pending and nothing initialises at startup yet), so the spec's "clearly documented splash-completion mechanism for this UI phase" is a timer; it does not imply that auth or the server is ready.
- **Changes:**
  - Fonts: `assets/fonts/Poppins-Bold.ttf` (Poppins 700) and `assets/fonts/Inter.ttf` (Inter variable font, weights selected through the `wght` axis) registered in `pubspec.yaml`, with their OFL licences in `assets/fonts/licenses/`. No runtime font download. `AppFonts` in `app_theme.dart` builds the Poppins/Inter text styles.
  - Theme: login colour tokens from the spec table added to `AppColors` (`card`, `textPrimary`, `textSecondary`, `fieldBackground`, `fieldBorder`, `placeholder`, `buttonDisabled`, `onButtonDisabled`, `checkboxBorder`, `footer`, `brandDot`) plus `error` (`#D93B3B`), which is not in the frame and is used for validation messages and error borders.
  - Routes: new `lib/app/router/app_routes.dart`; `App` now uses `initialRoute`/`routes` instead of `home`. Still plain `MaterialApp` routes; `go_router` is deferred to the auth/session work, as in DEC-001.
  - Splash: `SplashScreen` is now stateful with an `AnimationController` (`duration`, default 2.5 s, injectable for tests) driving a determinate `LinearProgressIndicator`. On `AnimationStatus.completed` it calls `pushReplacementNamed('/login')` once (`_navigated` guard, `mounted` check, controller disposed in `dispose`), so Back cannot return to the splash. This replaces the indeterminate bar from DEC-001 because the product owner asked for "progress bar finished → login".
  - Login: `lib/features/auth/presentation/screens/login_screen.dart` (scrollable `SingleChildScrollView` inside `Scaffold`, dark background, content capped at 440 dp wide and centred on tablets, `AnnotatedRegion` for light status-bar icons, tap-outside and drag dismiss the keyboard) composed of `login_brand_header.dart` (logo at 210 dp wide with `BoxFit.contain`, `SMART • AI` with the pink dot and 2.4 letter spacing at 65 % white, Poppins 21 title; the Figma top inset of 58 is used as the status-bar-inclusive inset, i.e. `max(58, safe-area top)`, not added on top of it), `login_form.dart` (white card, radius 24, 1 dp `#DFE5EB` border, 20 dp padding, soft shadow; `Form` + two `TextFormField`s with 52 dp min height, radius 16, `#F8FAFC` fill; email keyboard, no autocorrect/capitalisation, Next → password; password obscured with a show/hide toggle whose tooltip/semantics are "Show password"/"Hide password" and which cannot take focus; `Keep me signed in` 20 dp checkbox, radius 6, 2 dp border, toggled from box or label, state local only; full-width Sign In button with trailing arrow) and `login_footer.dart` (three centred lines, Inter 10 Medium, 16.25 line height, `#AEB8C2`).
  - Validation: email required + simple format regex, password required (no length or domain rule). `AutovalidateMode.onUnfocus` so nothing is red on open; after a Sign In attempt the form switches to `always`. Sign In is disabled until both fields are locally valid. The logo PNG already contains the Thai and English university names, so they are not repeated as text.
  - Temporary UI-only actions: Sign In dismisses the keyboard, validates and shows the snackbar `Sign-in is not connected yet.`; `Forgot Password?` shows `Password reset is not available yet.` Neither navigates or sends a request.
  - Added visual states not in the inspected frame: enabled Sign In button (`#273238` background, white text; the frame only shows the disabled `#EEF3F7`/`#AAB6C2` state), focused field border (`#273238`, 1.5 dp), error border/text (`#D93B3B`), checked checkbox (`#273238` fill, white tick).
  - Icons: Material `mail_outline`, `lock_outline`, `visibility_outlined`/`visibility_off_outlined` and `arrow_forward` at 18/16 dp stand in for the Figma icons, which could not be exported without design access. As in the frame, the toggle shows the crossed-out eye while the password is hidden and the open eye once it is shown.
  - Splash fix found during the Android check: on a cold start the emulator laid out one frame before the window had a size, so `_RuledText` received a negative `maxWidth` (`contentWidth = 0 − 64`) and asserted (`BoxConstraints has non-normalized width constraints`). The width is now clamped to ≥ 0 before it reaches the text constraints. Pre-existing since DEC-001; it never showed on iOS or in widget tests.
  - Tests: `test/widget_test.dart` now covers splash → login replacement (and that Back cannot pop), login content with the disabled button, password toggle keeping text, checkbox toggling from box and label, enable/disable with valid input and the Sign In message, Forgot Password message, and no overflow at 320 × 480 with 1.6× text scaling.
- **Affected files:** `pubspec.yaml`, `assets/fonts/Poppins-Bold.ttf`, `assets/fonts/Inter.ttf`, `assets/fonts/licenses/OFL-Poppins.txt`, `assets/fonts/licenses/OFL-Inter.txt`, `lib/app/app.dart`, `lib/app/router/app_routes.dart`, `lib/app/theme/app_theme.dart`, `lib/features/splash/presentation/screens/splash_screen.dart`, `lib/features/auth/presentation/screens/login_screen.dart`, `lib/features/auth/presentation/widgets/login_brand_header.dart`, `lib/features/auth/presentation/widgets/login_form.dart`, `lib/features/auth/presentation/widgets/login_footer.dart`, `test/widget_test.dart`, `spec-md/00-changes-and-decisions.md`
- **Validation:** `dart format .` (clean), `flutter analyze` (no issues), `flutter test` (9 passed). iOS: iPhone 17 Pro simulator (iOS 27): splash fills its bar and is replaced by login after 2.5 s; logo proportions correct; fields accept text; errors appear only after leaving a field or pressing Sign In; the card grows for error text; Sign In stays disabled while empty/invalid; footer sits above the home indicator; no overflow. Android: Pixel 10 Pro emulator (API 37, 1280 × 2856): login renders as designed with the same layout as iOS; the first cold start logged the `_RuledText` assertion described above, and after the fix two further cold starts ran with no exceptions in the `flutter run` log. Physical devices not tested.
- **Follow-up:**
  - Sign in to the Figma connector and compare the screen with node `5:2` (icon shapes, shadow, exact spacing); swap the Material icons for the exported Figma icons if they differ.
  - Replace the splash timer with the real startup/session-restore signal and the named routes with `go_router` redirects when authentication is implemented; the timer must not survive as a fake "initialisation".
  - "Keep me signed in" has no effect until token storage exists.

### DEC-006 — Home screen (Figma `3:209`) and development-only demo login

- **Date:** 2026-10-27
- **Status:** Implemented
- **Module:** `features/home`, `features/auth`, `core/widgets`, `app/` (routes, theme), assets
- **Context:** `spec-md/03-home-page-screen.md` asks for the Home Page Screen from the Figma frame `Home Page Screen` (node `3:209`, 402 × 874, content ≈ 1607 tall) with static demo data, plus a temporary static login that opens Home. This replaces the "Sign-in is not connected yet." behaviour from DEC-005.
- **Decision:** Build Home as native widgets from the inspected frame. The Figma MCP connector worked this time, so layout, typography, colours and icons come from `get_design_context` for node `3:209` (sub-nodes `3:215` header, `3:260` next class, `3:334` AI card, `3:392` quick actions, `3:468` deadlines, `3:544` announcements, `3:595` bottom navigation). Add a small `DemoAuthService` that checks fixed demo credentials in memory and replaces the route stack with `/home`.
- **Reason:** The spec lists the frame and requires Figma assets rather than substitutes; the demo login gives Hsu a way to reach Home without fake backend authentication or stored tokens.
- **Changes:**
  - Assets: 23 SVG icons and the header circle artwork exported from the frame into `assets/icons/home/`, and the five bottom-navigation icons into `assets/icons/nav/`, all registered in `pubspec.yaml`. Drawn with `flutter_svg` (new dependency, `^2.3.0`) at their Figma sizes; no runtime Figma URLs. Colours are the ones baked into each SVG, except the navigation icons, which are tinted dark (active) or `#8797A8` (inactive). Fonts reuse the bundled Poppins Bold and Inter variable font (DEC-005). The avatar shows the initial `S`, not the university logo.
  - Theme: home colour tokens added to `AppColors` (`pageBackground`, `avatar`, `textMuted`, `divider`, `inactiveDot`, `accentBlue`, `accentBlueLight`, `timePanel`, `success`, `urgent`, `urgentLight`, `amber`, `amberText`, `amberLight`); `AppShadows` added for the card, raised, dark-card and dark-button shadows from the frame; `AppFonts.poppinsBold` gained an optional `height`.
  - Home: `HomeScreen` is one `Scaffold` whose body is a single `SingleChildScrollView` (header, then cards with 16 padding and 16 gaps, 32 bottom padding, cards capped at 600 wide and centred on tablets) and whose `bottomNavigationBar` is the fixed `AppBottomNavigation`. Header uses `max(58, safe-area top) + 14` as its top inset, so the system inset is not added twice; the circle artwork is pinned top-right at its 402 × 177.75 Figma size. Widgets: `home_header.dart`, `next_class_card.dart`, `ai_assistant_card.dart`, `quick_actions_grid.dart` (rows of three equal-height tiles, University alone on the last row; switches to two columns when large text would make tiles narrower than 96 dp), `deadline_card.dart`, `announcements_section.dart`, plus shared `home_surface.dart` (bordered surface with shadow and ink, badge, section heading) and `home_icons.dart`.
  - Bottom navigation: `lib/core/widgets/app_bottom_navigation.dart` (no app shell existed). Five destinations, Home selected with the 10 % dark background and the 24 × 2 indicator on the top border; bottom safe-area inset added below the 4 dp Figma padding.
  - Demo data: `lib/features/home/presentation/demo/home_demo_data.dart` holds the greeting, avatar initial, notification count, fixed date `Sunday, October 25, 2026`, next class, AI suggestions, quick actions, deadlines (labels kept as designed, not recalculated) and announcements as typed immutable constants, marked as demo data in the source.
  - Temporary actions: notification bell, View Class, Navigate, AI suggestions, Ask AI Assistant, quick-action tiles, deadline and announcement rows, See all, and the four other tabs show a SnackBar `<Feature> is not implemented yet.` and stay on Home with Home still selected. No destination screens, permissions, external navigation or requests.
  - Demo login: `lib/features/auth/data/demo_auth_service.dart`. Enabled in debug and profile builds and disabled in release builds unless built with `--dart-define=DEMO_LOGIN=true` (`--dart-define=DEMO_LOGIN=false` turns it off in debug). Email is trimmed and compared case-insensitively, the password exactly. On a match `LoginForm` calls `pushNamedAndRemoveUntil('/home', (_) => false)` once (a `_navigating` flag also disables Sign In), so Back cannot return to Login or the splash. On a mismatch it shows `Invalid email or password.` and stays on Login. The session is an in-memory flag only: no token, password or secure/shared storage, nothing logged; a fresh launch goes through the splash to Login again. "Keep me signed in" is still local-only. When the service is disabled, Sign In falls back to the DEC-005 message.
  - Routes: `/home` added to `AppRoutes` and the `MaterialApp` route table. No route guard, since Home is only reachable from the demo sign-in and no production authentication exists yet.
  - Status bar: the header scrolls with the page, so a dark strip the height of the top safe area stays fixed behind the status bar to keep its light icons readable after scrolling. Not in the static frame; added for scrolling.
  - Tests: `test/home_screen_test.dart` (main sections, seven quick actions in order with University alone in column one, scrolling to the last announcement with the navigation still visible, five navigation items with Home selected, unavailable-action messages without navigation, no overflow at 320 × 568 with 1.6× text). `test/widget_test.dart`: the old "does not authenticate" test now covers wrong credentials (including a password with a leading space) staying on Login, plus new tests for demo credentials opening Home once with no way back, and empty-field validation messages.
- **Affected files:** `pubspec.yaml`, `pubspec.lock`, `assets/icons/home/*.svg`, `assets/icons/nav/*.svg`, `lib/app/app.dart`, `lib/app/router/app_routes.dart`, `lib/app/theme/app_theme.dart`, `lib/core/widgets/app_bottom_navigation.dart`, `lib/features/auth/data/demo_auth_service.dart`, `lib/features/auth/presentation/widgets/login_form.dart`, `lib/features/home/presentation/screens/home_screen.dart`, `lib/features/home/presentation/demo/home_demo_data.dart`, `lib/features/home/presentation/widgets/{home_header,next_class_card,ai_assistant_card,quick_actions_grid,deadline_card,announcements_section,home_surface,home_icons}.dart`, `test/home_screen_test.dart`, `test/widget_test.dart`, `spec-md/00-changes-and-decisions.md`
- **Validation:** `dart format .` (clean), `flutter analyze` (no issues), `flutter test` (17 passed). The widget tests caught two problems that were fixed: the bottom bar's `Center` expanded to the full screen height, and the next-class header and deadline rows overflowed at 1.6× text. iOS (iPhone 17 Pro simulator, iOS 27): Home launched directly through a temporary entry point (deleted afterwards) with no exceptions or asset-loading errors, then the full app launched cleanly. Android (Pixel 10 Pro emulator, API 37): same two launches, no exceptions in the `flutter run` logs. The demo login on devices and a side-by-side visual comparison with the frame were left to the product owner; no screenshots were taken.
- **Follow-up:**
  - Replace `DemoAuthService` and its call in `LoginForm` with the real authentication API and `go_router` redirects; remove the demo credentials from the source then.
  - Replace `HomeDemoData` with the academic endpoints once their contracts are confirmed.
  - Wire the tabs and actions when their feature screens exist.

### DEC-007 — Login logo nudged to the right

- **Date:** 2026-10-27
- **Status:** Implemented
- **Module:** `features/auth` (login brand header)
- **Context:** After running the login screen on the simulator, the product owner asked for the Rangsit logo on the login screen to move "a little right".
- **Decision:** Add `LoginBrandHeader.logoShiftRight` (12 dp) and pad the logo's left side by twice that amount, so the centred `Column` places the artwork 12 dp right of the header's centre line. Width (210 dp), `BoxFit.contain` and the asset are unchanged; the splash screen's logo is not moved.
- **Reason:** The owner's visual judgement on the running app. No Figma measurement was taken for this nudge; 12 dp is a first value to adjust on feedback.
- **Changes:** `login_brand_header.dart`: new `logoShiftRight` constant and a `Padding(left: logoShiftRight * 2)` around the logo's `Semantics`/`Image.asset`.
- **Affected files:** `lib/features/auth/presentation/widgets/login_brand_header.dart`, `spec-md/00-changes-and-decisions.md`
- **Validation:** `dart format .` (clean), `flutter analyze` (no issues), `flutter test` (17 passed). Run on the iPhone 17 Pro simulator for the owner's check; no screenshots per the owner's instruction.
- **Follow-up:** Adjust the amount if 12 dp is not what the owner meant, and decide whether the splash logo should get the same nudge.

### DEC-008 — Profile screen (Figma `28:30`), signed-in app shell and local logout

- **Date:** 2026-10-27
- **Status:** Implemented
- **Module:** `features/profile`, `features/home` (screen is now a tab body), `features/auth` (demo sign-out), `app/` (shell, routes, theme, fonts), `core/widgets` (bottom navigation reused), assets
- **Context:** `spec-md/04-profile-screen.md` asks for the Profile Screen from the Figma frame `Profile Screen` (node `28:30`, 402 × 874, content ≈ 1556 tall) with static fixture data, the shared bottom navigation with Profile selected, placeholder feedback for every other action, and local logout through the existing demo-auth service. No backend or API.
- **Decision:** Build the screen as native widgets from the inspected frame (`get_design_context` and its screenshot for `28:30`; sub-nodes `28:37` header, `28:99` student information, `28:193` academic, `28:212` account, `28:255` app, `28:298` logout, `28:309` bottom navigation). Introduce a signed-in `AppShell` that owns the single Scaffold and bottom navigation and switches the tab bodies in an `IndexedStack`, instead of pushing a route per tab, so Home and Profile share one bar, repeated taps never stack routes and each opened tab keeps its scroll position. Logout clears the in-memory demo session and replaces the whole navigation stack with `/login`.
- **Reason:** The spec requires one shared navigation bar, no duplicate routes on repeated taps and scroll preservation "where the app shell supports it"; replacing routes per tab would animate the bar away with the page and lose scroll state. The shell is the interim, named-routes form of the future `go_router` stateful shell route (DEC-005). Tabs are built on first open only.
- **Changes:**
  - Assets: 19 SVGs exported from the frame into `assets/icons/profile/` (header circle artwork 402 × 477.5, settings gear, badge check, pencil, six information-row icons, seven menu icons, 14 dp chevron, logout arrow), registered in `pubspec.yaml` and drawn with `flutter_svg` at their Figma sizes through the shared `HomeIcon`. The profile chevron (14 dp, 1.6 stroke) differs from the home one (12 dp, 1.5), so it is a separate file. The bottom-navigation icons are the existing `assets/icons/nav/` files; the frame's exports differ only by the stroke colour, which the bar applies at runtime.
  - Fonts: `assets/fonts/Poppins-Black.ttf` (weight 900, OFL, from the Google Fonts repository) added to the Poppins family because the frame sets `My Profile`, the avatar initial and the name in Poppins Black; `AppFonts.poppinsBlack` added. Inter Black/Bold/SemiBold/Medium come from the bundled variable font as before. No runtime font download.
  - Theme: `AppColors.cardBorder` (`#E2E8EE`), `accentPurple` (`#8B5CF6`), `logoutBorder` (`#FCA5A5` at 13 %) and `textFaint` (`#AAB6C2`). Everything else reuses existing tokens (`background`, `pageBackground`, `textPrimary`, `textSecondary`, `textMuted`, `accentBlue`, `success`, `brandDot`, `amber`, `urgent`, `urgentLight`, `fieldBorder`) and `AppShadows.card`.
  - Shell: new `lib/app/shell/app_shell.dart` (`AppShell`, `tabs = [home, profile]`, `initialDestination`). It owns the `AnnotatedRegion` for light status-bar icons and the fixed dark strip behind the status bar that `HomeScreen` owned before; the AI Chat, Schedule and Campus tabs keep showing `<Tab> is not implemented yet.` without changing the selection. `HomeScreen` is now the tab body only (its `SingleChildScrollView`); its content, data and messages are unchanged.
  - Routes: `/home` → `AppShell()` with Home selected (the demo login still calls `pushNamedAndRemoveUntil('/home')`); new `/profile` → `AppShell(initialDestination: profile)`.
  - Profile: `profile_screen.dart` (tab body: header and content in one `SingleChildScrollView`; content capped at 600 dp and centred on tablets, 16 dp page margin, 20 dp between sections, 32 dp bottom padding), `profile_header.dart` (dark header with the circle artwork drawn at its 402 × 477.5 Figma size and centred so it is never scaled; `max(58, safe-area top) + 16` top inset so the system inset is not added twice; `STUDENT PORTAL` Inter Bold 9 at 50 % white with 0.9 tracking; `My Profile` Poppins Black 22; 42 dp translucent settings button, radius 16, inside a 48 dp touch target with the semantics label `Settings`; 96 dp rounded-square avatar at 20 % white with a 2 dp 40 % white border and card shadow, Poppins Black 36 initial, 24 dp green check badge with a 2 dp blue border overlapping the lower-right corner; name Poppins Black 20; `ID: <id>` Inter SemiBold 13 at 70 % white; the three statistic cards (15 % white, 20 % white border, radius 16, 20 × 12 padding, Inter Black 20 values, Inter SemiBold 9 labels at 60 % white) in a centred `Wrap` with 12 dp gaps so they hug their content as in the frame and wrap instead of overflowing at large text; white `Edit Profile` pill 40 dp high, radius 16, Inter 12, pencil icon 13 with an 8 dp gap), `profile_stat_card.dart`, `profile_section.dart` (upper-case Inter Bold 10 `#66788A` heading with 1 dp tracking, card 12 dp below), `student_information_card.dart` (white card, radius 24, `cardBorder`, card shadow; rows at least 52 dp with 32 dp icon containers on the page colour, Inter SemiBold 11 label at most a third of the row, Inter Bold 11 value right-aligned in the remaining two thirds and wrapping, `pageBackground` dividers), `profile_menu_group.dart` + `profile_menu_tile.dart` (rows at least 60 dp, 40 dp icon container tinted with the accent at 9 %, Inter Bold 13 title over Inter 11 subtitle, 14 dp chevron, ink feedback), `profile_logout_section.dart` (52 dp pale-red `FilledButton`, radius 16, `logoutBorder`, red logout icon 16 and Inter 14 label; footer Inter Medium 10 in `textFaint` 12 dp below).
  - Demo data: `lib/features/profile/presentation/demo/profile_demo_data.dart` holds the fixture as typed immutable constants: name `Shein`, initial `S`, student ID `6512345678`, statistics `3.42 CGPA`, `87 CREDITS`, `5 COURSES`, the seven Student Information rows (Major `Computer Science`, Academic Year `Year 3`, Faculty `Faculty of Information Technology`, Department `Computer Science`, Program `Bachelor of Science`, Semester `Semester 1 / 2026`, Email `6512345678@rsu.ac.th`), the Academic/Account/App menu rows with their accent colours and a `ProfileAction`, and the preview strings `SMART AI v2.0.1` and `SMART AI University Assistant v2.0.1` (not the real build version). These values reproduce the inspected frame and are deliberately separate from the demo-login identity (`6708457@rsu.ac.th`, DEC-006): the demo credentials only gate local access and were not changed, and no password appears in the profile files.
  - Placeholder actions (SnackBars; nothing navigates, requests permissions or persists state): settings button and Settings row share one callback → `Settings is not implemented yet.`; Edit Profile and Personal Information → `Profile editing is not implemented yet.`; Notification Preferences → `Notification preferences are not implemented yet.`; Change Password → `Password changes are not implemented yet.`; My Courses → `My Courses is not implemented yet.`; Help → `Help is not implemented yet.`; About → `About is not implemented yet.`
  - Logout: `DemoAuthService.instance.signOut()` (existing method) then `pushNamedAndRemoveUntil('/login', (_) => false)`, guarded against a second tap during the transition. The shell and both tab bodies are disposed with the route, so the selected tab and scroll positions reset; nothing else holds student state yet. No API call, no token storage, no confirmation dialog (not in the design).
  - Tests: new `test/profile_screen_test.dart` (header, identity and statistics; seven information rows in order with the Faculty value wrapping; every section reachable with the navigation fixed; Home ↔ Profile switching with one bar and no pushed routes; unimplemented tabs keep Profile selected; scroll position kept across tab switches; every placeholder message; logout to Login with no way back and `isSignedIn == false`; no overflow at 320 × 568 with 1.6× text). `test/home_screen_test.dart` now pumps `AppShell`. `test/widget_test.dart` adds the end-to-end login → Profile → Logout → Login flow.
- **Affected files:** `pubspec.yaml`, `assets/fonts/Poppins-Black.ttf`, `assets/icons/profile/*.svg`, `lib/app/app.dart`, `lib/app/router/app_routes.dart`, `lib/app/shell/app_shell.dart`, `lib/app/theme/app_theme.dart`, `lib/features/home/presentation/screens/home_screen.dart`, `lib/features/profile/presentation/screens/profile_screen.dart`, `lib/features/profile/presentation/demo/profile_demo_data.dart`, `lib/features/profile/presentation/widgets/{profile_icons,profile_header,profile_stat_card,profile_section,student_information_card,profile_menu_group,profile_menu_tile,profile_logout_section}.dart`, `test/profile_screen_test.dart`, `test/home_screen_test.dart`, `test/widget_test.dart`, `spec-md/04-profile-screen.md` (spec supplied by the product owner), `spec-md/00-changes-and-decisions.md`
- **Validation:** `dart format .` (clean), `flutter analyze` (no issues), `flutter test` (26 passed). iOS (iPhone 17 Pro simulator, iOS 26.5): Profile opened directly through a temporary entry point (deleted afterwards) with no exceptions or asset/font-loading errors in the `flutter run` log, then the normal entry point started through the splash to login with no exceptions. Android (real Samsung SM A366B, Android 16 / API 36, 1080 × 2340, connected by USB): the Profile entry point installed and launched with no exceptions in the log, including the zero-width first frame; the phone's screen went to sleep before a visual check, so only the log was checked there. The Pixel 10 Pro emulator was not used this time. The demo login → Profile → Logout flow on devices and the side-by-side comparison with the frame are left to the product owner; no screenshots were taken.
- **Follow-up:**
  - Visual comparison with the frame is left to the product owner on the running app (no screenshots, per the owner's instruction); points to confirm there are the Poppins Black weights, the statistic card widths and the header artwork placement on non-402-wide screens.
  - `HomeSurface` and `HomeIcon` are imported from `features/home` by the profile widgets; move them to `core/widgets` when a third feature needs them.
  - Replace `AppShell`'s named routes with a `go_router` stateful shell route and `ProfileDemoData` with the academic profile endpoint when they are integrated; wire the AI Chat, Schedule and Campus tabs when their screens exist.
- **Review (2026-10-28):** Rechecked against the spec and the frame metadata for `28:30`. Tokens, typography, fixture values, section order, menu actions, shell navigation and logout matched. One fix: the 48 dp touch targets of the settings and Edit Profile buttons added about 10 dp of invisible height to the header (≈ 487 instead of 477.5), so the gap before the avatar is now 18.5, the gap before Edit Profile 12 and the header's bottom padding 28; measured at 402 × 874 the avatar initial and the Edit Profile label now sit at the frame's y positions and the header is 478.5 tall (the remaining 1 dp is text line-height rounding). Touch targets are unchanged. A second fix: the same touch padding left the visible 42 dp settings button 3 dp inside the frame's 20 dp right margin, so it is shifted 3 dp right (`Transform.translate`; the touch area moves with it). Measured in a widget test at 402 × 874 after both fixes: avatar initial y 161.5, name 252.5, statistic values 333.5, visible Edit Profile 406.5–446.5, settings button x 340–382 and bottom navigation y 807 all equal the frame; header 478.5 and section heading 498.5 are 1 dp off. Re-run: `dart format` clean for the profile, home, app and test files, `flutter analyze` no issues, `flutter test` 26 passed; iPhone 17 Pro simulator launched the Profile entry point and the normal entry point with 0 exceptions; the Samsung phone was not connected at recheck time. The report sent to the owner is `profile-screen-recheck.md` in the project library.

### DEC-009 — AI Chat screen (Figma `33:30`), local demo conversation and the shell's bottom slot

- **Date:** 2026-10-28
- **Status:** Implemented
- **Module:** `features/assistant` (new), `app/` (shell, routes, theme), `features/home` (AI card actions now open the chat), assets
- **Context:** `spec-md/05-ai-chat-screen.md` asks for the AI Chat screen from the Figma frame `Ai-Chat Screen` (node `33:30`, 402 × 874): dark assistant header with history and New Chat, five horizontally scrolling suggested prompts, the conversation with the initial greeting, a composer with attachment and Send, the shared bottom navigation with AI Chat selected, Home AI actions opening the chat, and a local-only demo send. No backend, Gemini, streaming, history, uploads or persistence.
- **Decision:** Build the screen as native widgets from the inspected frame (`get_design_context` and its screenshot for `33:30`; sub-nodes `33:36` header, `33:72` suggestions, `33:121` conversation, `33:141` composer, `33:151` bottom navigation). Conversation state lives in a `DemoChatController` (`ChangeNotifier` with the immutable message list, the composer's `TextEditingController` and its `FocusNode`) owned by `AppShell`, so the conversation and draft survive tab switches and are dropped with the shell on logout. The composer is not part of the tab body: while AI Chat is selected the shell places it in the Scaffold's bottom slot above the navigation bar (`_BottomArea`). `Agent.md` lists Riverpod, but it is not in the project; the spec's "existing approach" is the plain-widget pattern of DEC-006/008, so no state framework was added.
- **Reason:** Scaffold SnackBars sit at the body's bottom, so a composer inside the body would be covered for four seconds by the very "Demo mode" message the spec asks Send to show (the widget tests caught this: the attachment button became untappable after the history message). With the composer and the bar in the bottom slot, SnackBars appear above the composer. The bar's slot also grows to the keyboard height, so the composer rises with the keyboard, the bar stays hidden behind it (restored when it closes) and the body shrinks once rather than being inset twice. This is the responsive keyboard decision the spec asks to record.
- **Changes:**
  - Assets: 12 SVGs exported from the frame into `assets/icons/ai_chat/` (header circle artwork 402 × 130, header robot 20, history 16, plus 11, the five prompt icons 13, avatar robot 17, paperclip 18, send arrow 15), registered in `pubspec.yaml` and drawn through the shared `HomeIcon`/`SvgPicture` at their Figma sizes; no runtime Figma URLs. The bottom-navigation icons are the existing `assets/icons/nav/` files (the frame's export differs only by stroke colour). Fonts reuse the bundled Poppins Bold and Inter variable font.
  - Theme: `AppColors.textPrompt` (`#44545F`, chip text) and `AppShadows.blueRaised` (the avatar's blue-tinted raised shadow). Everything else reuses existing tokens: `background`, `pageBackground`, `textPrimary`, `textMuted`, `fieldBorder` (borders and the disabled Send background), `accentBlue`, `success`, `avatar`, `AppShadows.card/raised/darkButton`.
  - Shell: `AppShell.tabs` gains `aiChat` (stacking order Home, AI Chat, Profile). The shell creates and disposes the `DemoChatController`, unfocuses before any tab switch so the keyboard stays with the chat, exposes `onOpenAssistant`/`onAskAssistant` to `HomeScreen`, and builds `_BottomArea(footer: ChatComposer while AI Chat is selected, navigation: AppBottomNavigation)`; the bar sits in a box whose minimum height is the keyboard inset. Route `/ai-chat` added (`AppRoutes.aiChat`) alongside `/home` and `/profile`.
  - Header (`ai_chat_header.dart`): dark `#273238`, circle artwork drawn at 402 × 130 and centred, never scaled; top inset `max(58, safe-area top) + 12` so the system inset is not added twice, 20 dp sides, 16 dp bottom (130 tall at the reference size). 44 dp translucent robot badge (15 % white, 20 % white border, radius 16, card shadow), `AI Assistant` Poppins Bold 17/21.25, status line Inter Medium 10/15 at 70 % white with the 8 dp green dot 6 dp before it; 36 dp history button and 36 dp `New Chat` pill (plus 11, Inter Bold 10) with the same translucent style, each inside a 44 dp tall touch area (the history area is 44 wide, so the gap after it is 8 to keep the designed 12 between visuals). Title and status are single-line with ellipsis as in the frame (`nowrap`); the `New Chat` label scales up to 1.3× so the row still fits a 320 dp screen at the largest text size.
  - Suggested prompts (`suggested_prompts_strip.dart`): white strip with a bottom border, 10 dp vertical padding, `SUGGESTED` Inter SemiBold 10 `#8797A8` at 16 dp, then a horizontal `SingleChildScrollView` (16 dp padding, 8 dp gaps) of pill chips (`HomeSurface`, 34 dp minimum, 10 × 7 padding, icon 13, 6 dp gap, Inter 10 `#44545F`) in the frame's order. Tapping copies the exact text into the composer with the cursor at the end and focuses it; nothing is sent. A different non-blank draft is kept and `Send or clear your current message first.` is shown.
  - Conversation (`ai_chat_screen.dart`, `chat_message_bubble.dart`): `ListView.separated` on `#F3F6FA`, 16 dp padding and gaps, items keyed by message id, bubbles capped at 600 dp on tablets. Assistant row: 36 dp blue avatar (radius 16, white robot 17, blue raised shadow) 2 dp down, 10 dp gap, white bubble (border `#DFE5EB`, raised shadow, 16 × 12 padding, radii 6 top-left / 24 elsewhere, at most 303.4 wide) with Inter 12/19.5, timestamp Inter 9 muted 4 dp below with a 4 dp inset. The initial greeting `Hi Shein! How can I help with your university life today?` with `09:00 AM` is a fixed fixture (`ChatDemoData.greeting`). Added user style (not in the frame): right-aligned dark `#273238` bubble with white text, border `avatar`, dark-button shadow, small top-right corner, timestamp from the device clock in the same `hh:mm AM` format. A new message scrolls to the end; New Chat returns to the top; other rebuilds leave the position alone. The list dismisses the keyboard on drag. When the body is shorter than 300 dp (keyboard open on a small phone) the suggestion strip is left out so the composer and some conversation still fit under the header.
  - Composer (`chat_composer.dart`): white bar with a top border, 16 / 10 / 16 / 14 padding; input container `#F3F6FA`, border, radius 24, minimum 50 tall, 12 / 6 / 8 / 6 padding; paperclip 18 in a 36 × 38 area (`Attach file`), multiline `TextField` (1 to 4 lines, then scrolls; Enter inserts a newline; collapsed decoration; Inter 13/19.5; hint `Ask about your university…` muted, single line) and the 38 dp Send button (`Send message`, radius 16, arrow 15). Send is disabled on grey `#DFE5EB` while the draft is blank, as in the frame; when non-blank text exists it uses the dark primary treatment of the Sign In and Navigate buttons (white arrow, dark-button shadow), an added state. Send trims the draft, appends one user message, clears the field and shows `Demo mode: AI responses are not connected yet.`; a second tap finds an empty draft and does nothing. The attachment button shows `Attachments are not available in this demo.`; no permission is requested. Buttons stay on the last line while the field grows.
  - New Chat: resets to the greeting, clears the draft and dismisses the keyboard. If user messages or a non-blank draft exist, an added confirmation dialog (`Start a new chat?` / `This will clear the current demo conversation.` / `Cancel`, `New Chat`) is shown first; otherwise it resets at once. History shows `Chat history is not available in this demo.`; no history screen.
  - Home integration: `HomeScreen` takes `onOpenAssistant` and `onAskAssistant`. Ask AI Assistant opens the AI Chat tab with the composer as it is; a Home suggested question opens the tab with the question in the composer (cursor at the end, not sent, not focused). An existing different draft is kept and the same `Send or clear…` message is shown. The intent is applied once in the tap handler, not on rebuilds. Home's appearance is unchanged; its other actions keep their "not implemented yet" messages.
  - Navigation: AI Chat is selected while visible; repeated taps change nothing; Home and Profile switch without pushing routes; Schedule and Campus keep the shell's placeholder message; the conversation, draft and list scroll position survive tab switches through the controller and the `IndexedStack`. Android Back with the keyboard open is handled by the system IME (it closes the keyboard first); nothing was added.
  - Session: no database, preferences, token, logging or API key. Logout replaces the route stack with `/login`, which disposes the shell and the controller, so the next sign-in starts with the greeting and an empty composer (covered by an end-to-end test).
  - Demo data: `lib/features/assistant/presentation/demo/chat_demo_data.dart` holds the title, the static `Online · Ready to help` preview label (no connection check), the hint, the greeting and the five prompts with their icons as typed immutable constants, marked as demo data in the source.
  - Tests: new `test/demo_chat_controller_test.dart` (greeting start, prefill rules, blank-send rejection, trimmed send with `01:07 PM` from an injected clock, unique ids across resets, reset, unmodifiable list, 12-hour formatting) and `test/ai_chat_screen_test.dart` (frame content with AI Chat selected; all five chips reachable on one row by scrolling; chip prefill with cursor and focus and the kept-draft message; whitespace cannot be sent, Send adds one right-aligned message, clears the field and shows the demo message with no reply; New Chat with and without the dialog, Cancel and confirm; history and attachment messages; Home actions opening the tab with and without prefill and the kept draft; conversation and draft surviving Profile and back, unimplemented tabs; composer above a simulated 300 dp keyboard at 402 × 874 and at 320 × 568 with 1.6× text; no overflow at 320 × 568 with 1.6× text including a long wrapped user message scrolled into view). `test/widget_test.dart` adds login → AI Chat → send → Profile → Logout → login → AI Chat showing only the greeting. The Home test's AI-suggestion assertion moved to the new file.
- **Affected files:** `pubspec.yaml`, `assets/icons/ai_chat/*.svg`, `lib/app/app.dart`, `lib/app/router/app_routes.dart`, `lib/app/shell/app_shell.dart`, `lib/app/theme/app_theme.dart`, `lib/features/home/presentation/screens/home_screen.dart`, `lib/features/assistant/presentation/{models/chat_message,demo/chat_demo_data,controllers/demo_chat_controller,screens/ai_chat_screen,widgets/ai_chat_icons,widgets/ai_chat_header,widgets/suggested_prompts_strip,widgets/chat_message_bubble,widgets/chat_composer}.dart`, `test/ai_chat_screen_test.dart`, `test/demo_chat_controller_test.dart`, `test/home_screen_test.dart`, `test/widget_test.dart`, `spec-md/05-ai-chat-screen.md` (spec supplied by the product owner), `spec-md/00-changes-and-decisions.md`
- **Validation:** `dart format .` (clean), `flutter analyze` (no issues), `flutter test` (48 passed). The widget tests caught four problems that were fixed before this entry: SnackBars covering the composer (moved to the bottom slot, above); at 320 dp with 1.6× text the `New Chat` pill left the title no width, so it wrapped glyph by glyph and the header grew past the screen (single-line header texts, label scale capped at 1.3×); the empty composer was four lines tall because the hint wrapped (single-line hint); and the scroll-to-new-message never ran because its last-seen count was a lazily initialised field first read inside the listener (now set in `initState`). iOS (iPhone 17 Pro simulator, iOS 26.5): the AI Chat tab launched directly through a temporary entry point (`lib/zz_ai_chat_check.dart`, deleted afterwards) with 0 exceptions and no asset- or font-loading errors in the `flutter run` log over the first 25 seconds. Android (Pixel 10 Pro emulator, API 37): same entry point, 0 exceptions including the zero-width first frame; the only error-level lines were the emulator's own (Bluetooth HAL, `SurfaceSyncGroup` timeouts, skipped frames while the debug build started). Typing, sending, New Chat, the keyboard and the side-by-side comparison with the frame on devices are left to the product owner; no screenshots were taken.
- **Follow-up:**
  - Visual comparison with the frame is left to the product owner on the running app (no screenshots, per the owner's instruction); points to confirm there are the header artwork placement on non-402-wide screens, the chip and composer heights, and the added user-bubble and enabled-Send styles.
  - Replace `DemoChatController.send` with the assistant endpoint (request, streaming reply, error states) and the static status label with real connection state; add history and attachments when their APIs exist; then remove the demo messages.
  - `HomeSurface` and `HomeIcon` are now imported from `features/home` by a third feature; move them to `core/widgets` in a cleanup change.
  - On very narrow screens with large text the header title truncates; collapsing `New Chat` to its icon there would free the width if the owner wants it.
  - Replace `AppShell`'s named routes with a `go_router` stateful shell route when authentication is integrated.


### DEC-010 — Student Login API Integration

- **Date:** 2026-10-29.
- **Scope:** Replace the development-only demo sign-in (DEC-006) with a
  real backend-authenticated session that follows `spec-md/06-login-auth-api.md`.
  The Figma login layout stays unchanged; only the data path moves.
- **Verified backend contract (read-only inspection of the Spring Boot
  project at `backend/seniorproject`, which Hsu confirmed must not be
  modified):** base path `/api/v1/student/auth`. Login is
  `POST /login` with `{"universityEmail","password"}` and returns
  `{"tokenType":"Bearer","accessToken","expiresIn","refreshToken",
  "refreshExpiresIn","forcePasswordChange","user"}` where `user` is the
  `StudentMeResponse` identity record. Refresh is `POST /refresh` with
  `{"refreshToken"}` returning the same shape (rotated tokens). Logout
  is `POST /logout?allDevices=` (bearer required). Profile is
  `GET /me` (bearer required). Errors come back as the shared
  `ApiError` envelope (`timestamp`, `status`, `code`, `message`,
  `path`, `traceId`). The error codes mapped by the mobile client are
  `INVALID_STUDENT_CREDENTIALS` (401), `STUDENT_ACCOUNT_NOT_ACTIVE`
  (403), `STUDENT_ACCOUNT_LOCKED` (423), `TOO_MANY_REQUESTS` (429),
  `AUTH_SERVICE_UNAVAILABLE` / `AUTH_SESSION_UNAVAILABLE` (503),
  `INVALID_REFRESH_TOKEN` (401), `PASSWORD_CHANGE_REQUIRED` (403) and
  `VALIDATION_ERROR` (400). Access-token TTL is 15 minutes;
  refresh-token TTL is 7 days (backend defaults). The backend
  lowercases and trims `universityEmail` and only accepts the RSU
  domain; the mobile client sends the trimmed value and the password
  as typed, with no transformation.
- **Verified development environment:** iOS Simulator points at
  `http://localhost:8080` (built-in default from `AppConfig`); Android
  Emulator uses `http://10.0.2.2:8080` through the same default.
  Override with `--dart-define=API_BASE_URL=…` for a physical phone or
  a hosted test environment. HTTPS is enforced for release and profile
  builds. Plain HTTP to localhost / 10.0.2.2 / 127.0.0.1 is permitted
  only in debug builds via `android/app/src/debug/res/xml/network_security_config.xml`
  and the iOS `NSAppTransportSecurity` / `NSExceptionDomains` entries
  in `ios/Runner/Info.plist` (production hosts are HTTPS-only, since
  release builds use the main manifest).
- **Removal of static authentication:** `DemoAuthService` is deleted
  along with the `DEMO_LOGIN` dart-define, the hardcoded
  `6708457@rsu.ac.th` / `P@ssw0rd` credentials and every demo-only
  bypass. The login form now goes through [`AuthController.login`](../lib/features/auth/presentation/controllers/auth_controller.dart);
  Profile Logout goes through [`AuthController.logout`](../lib/features/auth/presentation/controllers/auth_controller.dart).
  There is no local fallback when the backend is unreachable; the
  user sees the mapped network / timeout / server-error message and
  stays on the login screen.
- **Session persistence and refresh decisions:**
  - Access tokens live only in memory inside `TokenStore` (DEC-010).
  - Refresh tokens are kept in memory for the current app process and,
    when Keep Me Signed In is checked, persisted through
    `SecureSessionStorage` (`flutter_secure_storage`, Keychain /
    EncryptedSharedPreferences). The persisted key is
    `student_refresh_token.v1`.
  - Unchecked Keep Me Signed In clears any previously persisted token
    at both login and logout, so a fresh launch always lands on login.
  - On launch, [`AuthController.restore`](../lib/features/auth/presentation/controllers/auth_controller.dart)
    reads the persisted refresh token and calls `/refresh` once. On
    success the rotated refresh token is re-persisted. On an explicit
    `ApiException` (401 `INVALID_REFRESH_TOKEN`, 403 account state)
    the persisted token is wiped and the user lands on login with a
    short message. On a network / timeout error the persisted token is
    kept and the splash shows an error panel with Try Again; retrying
    runs `restore()` again.
  - Logout calls `/logout`, swallows any failure, wipes the in-memory
    tokens, deletes any persisted refresh token and flips to
    `unauthenticated`. The sequence counter inside the controller
    guarantees a late response to an in-flight login or restore cannot
    bring the just-killed session back.
  - Automatic refresh-on-401 against protected endpoints is **not**
    implemented in this change: the only authenticated requests
    today are `/logout` (fire-and-forget) and startup `/refresh`. When
    additional protected endpoints land (academic APIs, assistant
    chat), the auth interceptor should coordinate refreshes
    exactly as section 12 of `spec-md/06-login-auth-api.md` describes.
  - `forcePasswordChange: true` does not prevent entry to Home yet
    (the mobile app has no change-password screen). The backend
    independently blocks every protected endpoint except `/me`,
    `/logout` and `/change-password` with
    `PASSWORD_CHANGE_REQUIRED`, so no stale authority leaks into
    future features. A dedicated change-password spec will add the
    screen and the proper banner.
- **Routing:** named routes are replaced by a top-level
  [`AuthGate`](../lib/features/auth/presentation/auth_gate.dart)
  reactive gate that renders the splash while initializing, the login
  screen while unauthenticated / submitting, and the signed-in shell
  (`AppShell`) with the authenticated `StudentUser` while authenticated.
  Logout no longer calls `Navigator.pushNamedAndRemoveUntil`; it just
  flips the controller status, which drops the signed-in shell from
  the tree. Protected screens are unreachable without an authenticated
  controller because the gate never builds them in any other state.
- **Student identity integration:** `HomeStudent` is now built from
  the authenticated student (`firstName`, `initial`, `programName · Year N`
  when available). `ProfileStudent` is built with the authenticated
  `firstName`, `initial`, and `studentCode`. The Student Information
  Email row uses the authenticated `universityEmail`. The remaining
  Student Information rows (Major, Academic Year, Faculty, Department,
  Program, Semester) and the stats (CGPA, Credits, Courses) stay as
  marked fixtures until a dedicated academic spec replaces them.
- **Login UI behavior:**
  - Email is trimmed before being sent; the password is sent as typed
    (no trimming, no case changes).
  - Sign In is disabled while the form is invalid and while a login is
    in flight; the button shows a 20 × 20 `CircularProgressIndicator`
    in place of the label at the same height, keeping dimensions.
  - A backend error renders as an inline banner above the Sign In
    button with the mapped user-safe message; typing in either field
    clears it. The email the user typed survives failed attempts.
  - "Keep me signed in" is disabled while a submission is in flight.
  - Forgot Password still shows the "not available yet" SnackBar.
- **Files changed (added, replaced or deleted):**
  - Added: [`lib/core/config/app_config.dart`](../lib/core/config/app_config.dart),
    [`lib/core/network/api_client.dart`](../lib/core/network/api_client.dart),
    [`lib/core/network/api_exception.dart`](../lib/core/network/api_exception.dart),
    [`lib/core/storage/session_storage.dart`](../lib/core/storage/session_storage.dart),
    [`lib/features/auth/data/auth_api.dart`](../lib/features/auth/data/auth_api.dart),
    [`lib/features/auth/data/token_store.dart`](../lib/features/auth/data/token_store.dart),
    [`lib/features/auth/data/models/student_user.dart`](../lib/features/auth/data/models/student_user.dart),
    [`lib/features/auth/data/models/login_response.dart`](../lib/features/auth/data/models/login_response.dart),
    [`lib/features/auth/presentation/controllers/auth_controller.dart`](../lib/features/auth/presentation/controllers/auth_controller.dart),
    [`lib/features/auth/presentation/auth_gate.dart`](../lib/features/auth/presentation/auth_gate.dart),
    `android/app/src/debug/res/xml/network_security_config.xml`,
    [`test/support/auth_fakes.dart`](../test/support/auth_fakes.dart),
    [`test/auth_controller_test.dart`](../test/auth_controller_test.dart),
    `spec-md/06-login-auth-api.md`.
  - Replaced: [`pubspec.yaml`](../pubspec.yaml) (adds `dio`, `flutter_secure_storage`),
    [`lib/main.dart`](../lib/main.dart) (composition root),
    [`lib/app/app.dart`](../lib/app/app.dart) (hosts `AuthController`,
    renders `AuthGate`),
    [`lib/features/splash/presentation/screens/splash_screen.dart`](../lib/features/splash/presentation/screens/splash_screen.dart)
    (no self-navigation; error / retry panel),
    [`lib/features/auth/presentation/screens/login_screen.dart`](../lib/features/auth/presentation/screens/login_screen.dart)
    (takes controller),
    [`lib/features/auth/presentation/widgets/login_form.dart`](../lib/features/auth/presentation/widgets/login_form.dart)
    (controller-driven, inline error banner, button spinner),
    [`lib/features/profile/presentation/screens/profile_screen.dart`](../lib/features/profile/presentation/screens/profile_screen.dart)
    (takes student + onLogout, no routing),
    [`lib/features/profile/presentation/demo/profile_demo_data.dart`](../lib/features/profile/presentation/demo/profile_demo_data.dart)
    (`studentFor` / `informationFor` factories),
    [`lib/features/home/presentation/screens/home_screen.dart`](../lib/features/home/presentation/screens/home_screen.dart)
    (takes student),
    [`lib/features/home/presentation/demo/home_demo_data.dart`](../lib/features/home/presentation/demo/home_demo_data.dart)
    (`studentFor` factory),
    [`lib/app/shell/app_shell.dart`](../lib/app/shell/app_shell.dart)
    (takes student + onLogout),
    [`android/app/src/debug/AndroidManifest.xml`](../android/app/src/debug/AndroidManifest.xml)
    (references the debug network security config),
    [`ios/Runner/Info.plist`](../ios/Runner/Info.plist) (localhost ATS
    exception), `test/widget_test.dart`, `test/profile_screen_test.dart`,
    `test/home_screen_test.dart`, `test/ai_chat_screen_test.dart`.
  - Deleted: `lib/features/auth/data/demo_auth_service.dart`.
- **Tests and manual checks performed:**
  - `dart format .` applied to every edited file.
  - `flutter analyze` reports no issues.
  - `flutter test` runs 58 tests, all passing. Coverage includes
    successful login, invalid credentials, validation without
    submission, duplicate-tap prevention (sequence counter), timeout
    and connection failure, malformed login response, secure-storage
    failure, Keep Me Signed In enabled vs disabled, valid session
    restoration, expired session restoration (persisted token wiped),
    temporary network failure during restoration (persisted token
    kept, Try Again recovers), logout cleanup, late-response handling
    after logout, chat / draft reset on logout, protected-route gating
    (unauthenticated → login) and the Figma layout checks on small
    devices with large text.
  - Manual: iOS Simulator (iPhone 17 Pro) debug build launched against
    the live Spring Boot backend running on this Mac via
    `http://localhost:8080`; Hsu drives the real sign-in.
- **Known limitations and follow-ups:**
  - Automatic refresh-on-401 against protected endpoints is deferred;
    see section 12 above.
  - `forcePasswordChange` is observed by the model but not surfaced
    in the UI yet; needs its own screen and a soft banner on Home.
  - Startup time can briefly show the splash on fast refreshes; a
    minimum visible delay is intentionally not added — the splash is
    already visually calm and the gate is responsive.
  - The Home header's `greeting` and `dateLabel` are derived from the
    local clock in this change; the `details` line uses the backend
    `programName` and `academicYear` when present, otherwise it is
    empty (no misleading fixture). Full academic data (CGPA, credits,
    courses, enrollment) still shows fixture values until a dedicated
    academic spec replaces them.
  - The debug HTTP exceptions on both platforms apply only to local
    development hosts (loopback / `10.0.2.2`); production builds reach
    the backend over HTTPS exclusively.

### DEC-011 — Physical-device backend connectivity (login timeout fix)

- **Date:** 2026-10-29.
- **Scope:** Follow-up to DEC-010. Login on a physical phone showed
  "The request timed out." while the iOS Simulator and Android emulator
  worked.
- **Root cause:** `AppConfig`'s development default is `localhost:8080`
  on iOS / macOS and `10.0.2.2:8080` on Android. `10.0.2.2` is the
  Android *emulator's* alias for the host loopback; on a physical
  Android it routes nowhere, so the request times out. A physical phone
  must target the Mac's LAN IP (or a tunnel), which the app cannot
  auto-discover.
- **Fix:**
  - Document and tool the `--dart-define=API_BASE_URL=http://<mac-lan-ip>:8080`
    override for physical devices. Added
    [`scripts/run_physical.sh`](../scripts/run_physical.sh) (auto-detects
    the Mac's Wi-Fi IP; `--reverse` sets up `adb reverse` for a
    USB-tethered Android instead) and `.vscode/launch.json` configs
    ("simulator or emulator" and "physical device").
  - Relaxed the dev-only cleartext rules so plain HTTP to the Mac's LAN
    IP is allowed in debug builds: Android
    [`network_security_config.xml`](../android/app/src/debug/res/xml/network_security_config.xml)
    now uses `base-config cleartextTrafficPermitted="true"` (debug
    manifest only); iOS [`Info.plist`](../ios/Runner/Info.plist) now
    sets `NSAllowsArbitraryLoads` + `NSAllowsLocalNetworking`. Release
    builds still use the main Android manifest (HTTPS-only) and reach
    the production API over HTTPS, so the iOS exception never applies
    there. (Follow-up: gate the iOS exception to debug via an xcconfig
    before any App Store submission.)
- **Verified development configuration:** Mac LAN IP `10.5.5.188` on
  `en0`; Docker exposes the backend on `0.0.0.0:8080`. Confirmed a
  physical Samsung (Android, Wi-Fi `10.5.0.x`, on the same routable
  network) reaches `http://10.5.5.188:8080/actuator/health/liveness`
  (HTTP 200) and, running the debug app built with
  `--dart-define=API_BASE_URL=http://10.5.5.188:8080`, a dummy sign-in
  returned the backend's 401 as "Invalid email or password." instead of
  a timeout — the full request/response round-trip works from the
  device. The iOS Simulator continues to use the `localhost:8080`
  default unchanged.
- **Files changed:** `android/app/src/debug/res/xml/network_security_config.xml`,
  `ios/Runner/Info.plist`, `.vscode/launch.json` (added),
  `scripts/run_physical.sh` (added). No Dart code changed;
  `flutter analyze` / `flutter test` from DEC-010 remain green.
- **Known limitations:** The Mac's LAN IP is not auto-discovered by the
  app; a physical-device run must pass the current IP via the
  dart-define (the script resolves it automatically, the IDE configs
  default to `10.5.5.188` and can be edited). If the Mac's IP changes,
  re-run `scripts/run_physical.sh` (it re-detects) or update the define.
