# 02 — Login Screen Design Implementation

## Objective

Implement the Flutter login screen matching the inspected Figma design.

Connect the existing loading screen to this login screen.

This task covers UI, local form interactions, and loading-to-login navigation only. Backend authentication integration will be implemented separately.

## Required Reading

Before implementation, read:

- `Agent.md`
- `spec-md/00-changes-decision.md`
- The existing loading-screen specification and implementation.

Follow existing project structure, theme, and routing conventions.

## Figma Reference

Direct login-screen link:

https://www.figma.com/design/RUhIF3MsPa9jTWfT0Dou02/Smart-Ai-University-Mobile?node-id=5-2&m=dev

- File key: `RUhIF3MsPa9jTWfT0Dou02`
- Frame: `Login Screen`
- Node ID: `5:2`
- Reference dimensions: `402 × 874`

Inspect this frame through Figma MCP before implementation and compare the finished screen with its screenshot.

Use native Flutter widgets. Adapt the design to responsive layouts rather than copying generated React code or absolute positioning.

## Scope

Implement:

- Dark full-screen background.
- University logo and branding.
- White login form card.
- Student email field.
- Password field with visibility toggle.
- Forgot Password action.
- Keep me signed in checkbox.
- Sign In button with arrow.
- Copyright footer.
- Transition from the existing loading screen.

Do not implement:

- Authentication API calls.
- Token storage or session persistence.
- Home/dashboard screens.
- Registration or password-reset screens.
- Backend changes.

Do not simulate successful authentication or navigate to a dashboard when Sign In is pressed.

## Logo

Use the existing asset:

`assets/images/rangsitlogo.png`

Requirements:

- Verify the asset exists.
- Preserve its original colors and aspect ratio.
- Use `Image.asset` with `BoxFit.contain`.
- Do not recreate, tint, stretch, or crop the logo.
- The Figma logo area is approximately 210 × 235.53 logical pixels.
- If the asset already includes the Thai and English university names, do not duplicate them as separate text.
- If its contents differ from the reference, report the mismatch.

Ensure the asset or its parent directory is registered in the existing `flutter.assets` section of `pubspec.yaml`.

## Design Tokens

Use existing theme tokens when they match these inspected values.

| Element | Value |
|---|---|
| Visible screen background | `#273238` |
| Login card | `#FFFFFF` |
| Primary text | `#273238` |
| Secondary text | `#66788A` |
| Field background | `#F8FAFC` |
| Card and field borders | `#DFE5EB` |
| Placeholder text | `#AAB6C2` |
| Disabled button background | `#EEF3F7` |
| Disabled button text | `#AAB6C2` |
| Checkbox border | `#CAD3DC` |
| Footer text | `#AEB8C2` |
| Branding separator dot | `#D80255` |

The outer Figma wrappers contain a light background, but the visible login screen itself is dark. Match the screenshot.

## Typography

Use the fonts shown in Figma:

- Poppins Bold for the main title and “Welcome back”.
- Inter for form labels, input text, buttons, branding, and footer.

Reference styles:

| Text | Size | Weight |
|---|---:|---|
| University Student Assistant | 21 | Bold |
| Welcome back | 18 | Bold |
| SMART • AI | 10 | Bold |
| Form subtitle | 11 | Regular |
| Field labels | 11 | Semibold |
| Input and placeholder text | 16 | Regular |
| Forgot Password? | 11 | Regular |
| Keep me signed in | 12 | Medium |
| Sign In | 13 | Regular |
| Footer | 10 | Medium |

The `SMART • AI` label uses approximately 2.4 letter spacing. Its text is white at 65% opacity, with the pink separator dot.

Bundle required fonts or reuse existing project font configuration. Avoid runtime font downloads for this screen.

## Screen Layout

### 1. Branding Area

At the reference size:

- Branding container height: approximately 397.
- Top inset before the logo: approximately 58.
- Horizontal padding: 20.
- Logo centered horizontally.
- Gap below the logo before `SMART • AI`: approximately 14.
- Gap before the main title: approximately 6.

Display these strings exactly:

- `SMART • AI`
- `University Student Assistant`

Treat the top inset as a reference measurement. Account for actual device safe areas without adding the inset twice.

### 2. Login Card

Reference geometry:

- Horizontal screen margin: 16.
- Width at reference size: approximately 370.
- Top position: approximately 381.
- Overlaps the branding container by approximately 16.
- Border radius: 24.
- Border width: 1.
- Inner padding: 20.
- Subtle dark shadow matching Figma.

Use content-driven height. The card must expand for validation messages and larger text rather than clipping them.

### 3. Card Heading

Display:

`Welcome back`

Subtitle:

`Enter your RSU credentials to continue.`

Use approximately 2 spacing above the subtitle and 20 spacing before the email section.

### 4. Student Email Field

Label:

`Student Email`

Placeholder:

`e.g. 6512345678@rsu.ac.th`

Appearance:

- Envelope icon on the left.
- Field height: at least 52.
- Border radius: 16.
- Horizontal content padding: approximately 16.
- Icon size: approximately 18.
- Gap between icon and text: approximately 12.
- Gap between label and field: approximately 6.

Behavior:

- Editable text input.
- Email keyboard.
- Disable autocorrect and automatic capitalization.
- Keyboard Next moves focus to Password.

### 5. Password Field

Place the label and action on the same row:

- Left: `Password`
- Right: `Forgot Password?`

Placeholder:

`Enter your password`

Appearance:

- Lock icon on the left.
- Eye/visibility icon on the right.
- Match the email field’s background, border, radius, and minimum height.
- Approximately 16 spacing before the password section.

Behavior:

- Obscure the password initially.
- Toggle visibility without clearing text or losing focus.
- Provide accessible “Show password” and “Hide password” labels.
- Do not trim or modify password input.

### 6. Keep Me Signed In

Display:

`Keep me signed in`

Appearance:

- Initially unchecked.
- Approximately 20 × 20 checkbox.
- Border radius: approximately 6.
- Border width: 2.
- Gap between checkbox and label: approximately 10.
- Follow Figma spacing below the password field.

Behavior:

- Tapping either the checkbox or its label toggles the value.
- Keep the value in local screen state only.
- Do not persist credentials or claim that a session is remembered.

### 7. Sign In Button

Display:

`Sign In`

Include the small right-arrow icon shown in Figma.

Appearance:

- Full card-content width.
- Height: at least 52.
- Border radius: 16.
- Gap between label and arrow: approximately 10.
- Approximately 16 spacing above the button.
- Match the inspected disabled state when inputs are empty.

Behavior:

- Disable the button when email format is invalid or password is empty.
- Once inputs are locally valid, allow the UI action.
- On press, dismiss the keyboard and validate the form.
- For this UI-only phase, show:
  `Sign-in is not connected yet.`
- Do not send a request, create tokens, or navigate to Home.

The inspected frame shows the empty/disabled button state.
Check for an enabled variant or reuse an established project primary-button style. Document any added state styling as an implementation decision.

### 8. Footer

Place the footer approximately 24 below the card.

Center these three lines:

`© 2026 Rangsit University`
`Smart AI University Student Assistant`
`All rights reserved.`

Use the reference footer color, 10-point Inter Medium, and approximately 16.25 line height.

## Icons

Match the envelope, lock, visibility, and arrow icons from Figma.

- Reuse matching local assets where available.
- Otherwise export/download the actual Figma icon assets.
- Store them locally and register them as necessary.
- Do not use temporary Figma URLs at runtime.
- Use accessible touch areas without enlarging the visible icon unnecessarily.

## Local Form Validation

Use a Flutter `Form` and `TextFormField` widgets.

For this design-only phase:

- Email is required and must have a valid email format.
- Password is required.
- Do not invent password length or complexity requirements.
- Do not apply the registration-only university-domain rule to login without a confirmed authentication contract.
- Do not show errors immediately when the screen first opens.
- Display errors after field interaction or a submit attempt.
- Keep error messages readable and allow the layout to expand.

These checks validate input only; they do not establish whether credentials are correct.

## Forgot Password Action

Preserve the action’s appearance and touch behavior.

Because password reset is outside this task:

- Do not build a new screen or invent an endpoint.
- On tap, show:
  `Password reset is not available yet.`

Document this temporary UI-only behavior in the decision log.

## Loading Screen to Login Navigation

Inspect the current loading-screen implementation first.

- Reuse its existing completion signal or established splash duration.
- After it completes, replace the loading route with `/login`.
- Do not push Login above Loading in the back stack.
- Ensure navigation happens only once.
- Avoid navigation calls directly inside `build`.
- Cancel timers and subscriptions when disposed.
- Prevent callbacks from navigating after disposal.
- Do not add a second artificial delay.

If startup has no completion behavior yet, implement a clearly documented splash-completion mechanism for this UI phase. It must not imply that authentication or server initialization has succeeded.

Preserve any already-working authenticated-session routing.

## Suggested Files

Follow existing project conventions. Suggested locations:

- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/widgets/login_brand_header.dart`
- `lib/features/auth/presentation/widgets/login_form.dart`
- `lib/features/auth/presentation/widgets/login_footer.dart`

Update the existing router and theme only as needed.

Do not create a second `MaterialApp` or introduce another state-management framework.

## Responsive and Keyboard Behavior

- Use a scrollable layout with safe-area and keyboard handling.
- Preserve the Figma composition at 402 × 874.
- Allow smaller screens to scroll.
- Keep both fields and the Sign In button reachable when the keyboard opens.
- Allow text to wrap or expand when accessibility text scaling requires it.
- Avoid fixed card heights and absolute positioning of form controls.
- Match system-bar appearance to the dark background where supported.
- Keep the footer in the scrollable content so it does not cover the form.

## Validation

Run:

    dart format .
    flutter analyze
    flutter test

Verify:

- Loading transitions to Login once.
- Back does not reopen Loading.
- Logo loads with the correct proportions.
- Fonts, colors, spacing, and assets match Figma.
- Inputs accept text correctly.
- Password visibility works.
- Checkbox toggles through both its box and label.
- Empty form shows the disabled Sign In state.
- Local validation works without pretending to authenticate.
- Forgot Password shows the documented temporary message.
- No overflow occurs with the keyboard or larger text.
- Existing tests are updated if the initial route changed.

Compare an emulator/device screenshot with Figma node `5:2`.
Report Android and iOS verification separately.

## Changes and Decision Log

Append an entry to:

`spec-md/00-changes-decision.md`

Include:

- Date and sequential decision ID.
- Figma frame `Login Screen`, node `5:2`.
- Files changed.
- Theme and asset decisions.
- Loading-to-login navigation behavior.
- Any added visual states not present in the inspected frame.
- Temporary UI-only actions.
- Validation performed and remaining work.

## Acceptance Criteria

- Login visually matches the inspected Figma frame.
- The existing loading screen transitions correctly to Login.
- `assets/images/rangsitlogo.png` is used.
- Local form interactions work.
- No authentication success is simulated.
- No backend or unrelated screen is modified.
- The change and decision log is updated.