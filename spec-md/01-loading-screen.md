# 01 — Loading / Splash Screen

## Objective

Implement only the Flutter application's initial loading/splash screen using the Figma design and the existing Rangsit University logo.

Read `Agent.md` and `spec-md/00-changes-decision.md` before starting.

## Design Reference

https://www.figma.com/design/RUhIF3MsPa9jTWfT0Dou02/Smart-Ai-University-Mobile?node-id=0-1&m=dev

- File key: `RUhIF3MsPa9jTWfT0Dou02`
- Entry node: `0:1`
- Locate the actual loading/splash screen frame before implementation.
- Inspect its screenshot, layout, background, typography, spacing, and loading indicator.
- Record the inspected screen node ID in the decision log.
- Do not assume the entry node is the loading screen.
- If Figma is inaccessible, request a screenshot of this screen. Do not invent design details or claim a visual match.

## Scope

Implement:

- Loading screen widget.
- Existing logo asset.
- Text and loading indicator shown in the inspected design.
- Responsive layout and safe-area handling.
- Initial-route integration with the existing app.

Do not implement:

- Login or registration screens.
- Home/dashboard screens.
- New authentication APIs.
- Backend changes.
- Native Android/iOS launch-screen customization.

This task covers the Flutter screen displayed after the platform's native launch screen.

## Logo Asset

Use this existing file:

`assets/images/rangsitlogo.png`

### Requirements

- Verify the file exists before referencing it.
- Reuse the supplied logo; do not redraw or substitute it.
- Preserve its original aspect ratio.
- Use `Image.asset` with `BoxFit.contain`.
- Match its size and position to the Figma frame.
- Avoid cropping, stretching, or tinting the logo.
- If the file is missing, report the missing asset.

Ensure `pubspec.yaml` includes the asset, unless its parent directory is already declared:

    flutter:
      uses-material-design: true
      assets:
        - assets/images/rangsitlogo.png

Merge this into the existing `flutter` section. Do not create a duplicate section.

## Implementation Structure

Follow existing project conventions.

Suggested file:

`lib/features/splash/presentation/screens/splash_screen.dart`

Use the existing application theme and router.

- Keep `main.dart` focused on application startup.
- Do not create a second `MaterialApp`.
- Reuse shared theme tokens and components where available.
- Add no external package solely for this screen unless the inspected design requires it.

## Layout Requirements

- Match the inspected Figma background and visual hierarchy.
- Use responsive constraints instead of fixed screen coordinates.
- Account for system insets and small devices.
- Preserve intended alignment without overflow.
- Support larger text sizes for any visible labels.
- Add only the text, branding, and indicator present in the design.
- Use indeterminate progress when actual progress is unknown.
- Do not display fabricated percentages.
- Add animation only when supported by the design or explicitly requested.

## Startup and Navigation Behavior

Inspect the existing startup and routing implementation first.

If startup/session initialization already exists:

- Display this screen while initialization is pending.
- Navigate once initialization completes.
- Use the existing destination and authentication rules.
- Replace the loading route so Back does not reopen it.
- Prevent duplicate navigation and callbacks after disposal.
- Reuse existing failure/retry handling.

If startup/session initialization does not exist:

- Make this screen available as the initial UI preview.
- Clearly report that automatic navigation is pending.
- Do not invent authentication logic or create a login screen.
- Do not add an arbitrary timer to simulate successful initialization.

## Validation

Run:

    dart format .
    flutter analyze
    flutter test

Update any starter test affected by changing the initial screen.

Verify:

- The logo loads successfully.
- Its aspect ratio is preserved.
- Layout matches the inspected Figma frame.
- No overflow occurs on small screens.
- Any loading indicator behaves correctly.
- Existing initialization and routing still work.
- No unrelated screens or backend files were changed.

Only claim emulator/device verification if it was performed.

## Change and Decision Log

Append an entry to:

`spec-md/00-changes-decision.md`

Record:

- Date and decision ID.
- Inspected Figma frame/node.
- Implemented layout and asset usage.
- Files changed.
- Startup/navigation behavior.
- Validation results.
- Missing design access or pending initialization work.

## Acceptance Criteria

- Only the loading/splash screen is implemented.
- The screen uses `assets/images/rangsitlogo.png`.
- Visual details come from the inspected Figma screen.
- The application opens the screen successfully.
- Existing startup behavior is preserved where available.
- Any preview-only behavior is explicitly documented.
- Relevant checks pass and the decision log is updated.