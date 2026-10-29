# 03 — Home Page Screen Design Implementation

## Objective

Implement the Home Page Screen in Flutter, matching the Figma design.

This task covers design and local UI interactions only. Use static demo data matching Figma. Backend integration and other feature screens are outside this task.

## Required Reading

Read before implementation:

- `Agent.md`
- `spec-md/00-changes-decision.md`
- Existing theme, routing, loading-screen, and login-screen code.

Reuse existing project components and conventions.

## Figma Reference

https://www.figma.com/design/RUhIF3MsPa9jTWfT0Dou02/Smart-Ai-University-Mobile?node-id=3-209&m=dev

- File key: `RUhIF3MsPa9jTWfT0Dou02`
- Frame: `Home Page Screen`
- Node ID: `3:209`
- Reference viewport: `402 × 874`

Use this exact frame. Do not mix it with `Home Page Screen - 2` or `Home Page Screen - 3`.

Inspect design context and screenshots before coding. Implement native Flutter widgets, not React code, a WebView, or a screenshot used as the screen.

## Scope

Implement all sections in this order:

1. Student greeting header.
2. Next Class card.
3. AI Assistant card.
4. Quick Actions grid.
5. Upcoming Deadlines.
6. Announcements.
7. Fixed bottom navigation.

Include content below the first viewport. The entire page must scroll.

Do not implement:

- Backend requests.
- Authentication or token management.
- Real notification subscriptions.
- AI requests or responses.
- Maps or location permissions.
- Assignment submission.
- Other feature screens.
- Database or backend changes.

## Design Tokens

| Usage | Color |
|---|---|
| Screen background | `#F3F6FA` |
| Header and dark cards | `#273238` |
| Avatar background | `#34434B` |
| White cards | `#FFFFFF` |
| Primary text | `#273238` |
| Secondary text | `#66788A` |
| Muted text and inactive navigation | `#8797A8` |
| Borders | `#DFE5EB` |
| Light dividers | `#EEF3F7` |
| Blue accent | `#01A2E5` |
| Pink accent | `#D80255` |
| Green status | `#16A34A` |
| Urgent red | `#DC2626` |
| Amber accent | `#F59E0B` |
| Amber text | `#D97706` |

Reference card shadow:

- Offset: approximately (0, 1), blur: 2, dark color at 4%.
- Offset: approximately (0, 4), blur: 12, dark color at 5%.

Reuse matching theme tokens. Avoid duplicating hardcoded styling across widgets.

## Typography

Use the fonts inspected in Figma:

- Poppins Bold for the student name and major card headings.
- Inter for supporting text, labels, badges, buttons, and navigation.

| Element | Reference size |
|---|---:|
| Student name | 19 |
| Greeting and student details | 11 |
| Header date | 10 |
| Course title | 15 |
| AI card heading | 14 |
| Section headings | 13 |
| Course code | 12 |
| Main row titles | 12 |
| Quick Action labels | 10 |
| Bottom navigation labels | 9 |

Use the inspected weights and line heights. Allow text to expand for accessibility instead of clipping it to the reference height.

## Overall Layout

- Use one Scaffold and the existing app router.
- The main content scrolls vertically.
- Bottom navigation remains fixed.
- Content horizontal padding: 16.
- Space between main sections: 16.
- Content top padding after the header: 16.
- Content bottom padding: approximately 32, with sufficient clearance for navigation.
- Main card radius: 16.
- Deadline and announcement container radius: 14.
- At the reference width, main cards are approximately 370 wide.

Use responsive constraints rather than hardcoding the screen to 402 × 874.

The reference content extends to approximately 1607 logical pixels. Do not use this as a fixed page height.

## 1. Student Greeting Header

Reference node: `3:215`

### Appearance

- Dark background: `#273238`.
- Reference total height: approximately 177.75.
- Horizontal padding: 20.
- Preserve the subtle decorative circular artwork shown in Figma.
- Greeting row starts around y = 72 in the reference frame.
- Account for actual device safe areas without adding top padding twice.

### Avatar

- Size: approximately 48 × 48.
- Rounded-square radius: 16.
- Background: `#34434B`.
- White border at approximately 30% opacity.
- Centered white initial: `S`.
- Small green status dot overlapping the lower-right corner.
- Status dot size: approximately 14, with a dark border.

Do not replace this avatar with the university logo. The inspected Home design uses a student initial.

### Greeting Text

Display these demo values:

- `Good Evening`
- `Shein`
- `Computer Science · Year 3`

### Notification Button

- Rounded square: approximately 44 × 44.
- Translucent white fill and border.
- Bell icon.
- Pink notification badge displaying `3`.

### Date Row

Display:

`Sunday, October 25, 2026`

Center the text between two subtle horizontal lines.

Keep the reference date and greeting fixed in this design preview. They are demo content, not current-date calculations.

## 2. Next Class Card

Reference node: `3:260`

### Container

- White background.
- Radius: 16.
- Thin border and subtle shadow.
- Reference height: approximately 229; allow expansion where needed.

### Dark Card Header

- Height: approximately 48.
- Horizontal padding: 16.
- Green status dot.
- Uppercase label: `NEXT CLASS`.
- Right-aligned translucent pill: `Starts in 45 min`.

### Course Information

Display:

- Course code: `CSC-452`
- Category badge: `Lecture`
- Course title: `Mobile Programming`

Use blue for the course code and the light-blue lecture badge.

Add the small time panel on the right:

- Start: `09:00`
- Thin divider.
- End: `11:45`

Reference time-panel size: approximately 52 × 44.

### Information Chips

Show three chips with matching icons:

- `Building 11`
- `Room 1103`
- `09:00 – 11:45`

Use light backgrounds, thin borders, and pill-shaped corners.

Allow chips to wrap on smaller screens.

### Buttons

Place two buttons side by side:

- `View Class`: dark outline, light background.
- `Navigate`: dark fill, white content.

Reference minimum height: 48.
Radius: 16.
Gap: approximately 10.

Use the actual calendar and location icons from the design.

The countdown and class times remain static demo values. Do not implement scheduling or navigation services.

## 3. AI Assistant Card

Reference node: `3:334`

### Container

- Dark background matching the header.
- Rounded corners: 16.
- Inner padding: 16.
- Subtle border and shadow.
- Reference height: approximately 302.

### Heading

- Robot icon inside a 40 × 40 blue-tinted container.
- Small green status dot.
- Blue uppercase label: `SMART AI`.
- White heading: `How can I help you today?`

### Suggested Questions

Display three full-width buttons:

1. `What's my next class?`
2. `Any assignments due?`
3. `Take me to next class`

Appearance:

- Translucent white background.
- Subtle translucent border.
- Radius: 16.
- Minimum height: approximately 46.
- Vertical gap: 8.
- Blue icons.
- Light text.

### Main Action

Below the suggestions, display:

`Ask AI Assistant`

- White background.
- Dark label and chat icon.
- Height: approximately 50.
- Radius: 16.
- Top spacing: approximately 12.

Do not send prompts or generate AI responses in this task.

## 4. Quick Actions

Reference node: `3:392`

Heading:

`Quick Actions`

### Grid

Use three columns at the reference width.

Preserve this order:

| Row | Column 1 | Column 2 | Column 3 |
|---|---|---|---|
| 1 | Timetable | Campus Map | Assignments |
| 2 | Exams | Study Assist | My Courses |
| 3 | University | Empty | Empty |

Do not stretch the University tile across the final row.

### Tile Styling

- White background.
- Thin border.
- Radius: 16.
- Subtle shadow.
- Approximately 10 spacing between tiles.
- Reference tile dimensions: approximately 116.7 × 88.5.
- Icon background: 44 × 44, radius 12.
- Icon: approximately 20.
- Label below icon, approximately 6 spacing.

### Icon Backgrounds

| Action | Background |
|---|---|
| Timetable | `#E8F5FC` |
| Campus Map | `#FCE8EF` |
| Assignments | `#EDE9FE` |
| Exams | `#FEF3C7` |
| Study Assist | `#DCFCE7` |
| My Courses | `#E8EDF5` |
| University | `#EEF2FF` |

Match each icon and its color to Figma.

Use a non-scrolling grid within the page scroll view or a sliver grid. Avoid competing vertical scroll areas.

Allow tile height or column count to adapt when large text would otherwise overflow.

## 5. Upcoming Deadlines

Reference node: `3:468`

### Heading Row

- Left: `Upcoming Deadlines`
- Right: red pill with white text: `1 due today`

### Demo Rows

| Course | Category | Title | Due label |
|---|---|---|---|
| CSC-452 | Assignment | Mobile UI Prototype | Today, 23:59 |
| CSC-401 | Midterm Exam | Data Structures Midterm | Thu, Oct 17 |
| CSC-311 | Assignment | Network Lab Report | Fri, Oct 18 |

These labels reproduce the design. Do not recalculate or “correct” the fixture dates for this visual implementation.

### Row Styling

- White card.
- Radius: 14.
- Thin border and subtle shadow.
- Reference height: approximately 62.
- Vertical gap: 10.
- Colored strip on the left, approximately 4 wide.
- Icon container: 36 × 36, radius 12.
- Course code and category badge above the title.
- Due label aligned to the right.

Color treatment:

- First row: red.
- Second row: amber.
- Third row: muted gray.

Allow height to grow for longer text or accessibility settings.

## 6. Announcements

Reference node: `3:544`

### Heading Row

- Left: `Announcements`
- Right: blue `See all` action.

### Container

- White background.
- Radius: 14.
- Thin border and subtle shadow.
- Three rows with subtle separators.
- Reference row height: approximately 60.

### Demo Content

| Title | Category | Time |
|---|---|---|
| Mid-term Exam Schedule Released | Academic | 2 hrs ago |
| Library Extended Hours: Oct–Nov 2026 | Campus | Yesterday |
| RSU Sports Day Registration Now Open | Events | 2 days ago |

### Appearance

- Small colored dot on the left.
- Title above category badge and relative time.
- Right chevron.
- First two rows have unread indicators.
- Third row uses muted styling.

Category styling:

- Academic: blue.
- Campus: green.
- Events: pink.

Do not implement announcement fetching or persistent read/unread state.

## 7. Fixed Bottom Navigation

Reference node: `3:595`

Display exactly five items:

1. Home
2. AI Chat
3. Schedule
4. Campus
5. Profile

### Appearance

- White background.
- Thin top border.
- Reference height: approximately 67 before device-specific safe-area adjustments.
- Icons: approximately 22.
- Labels: approximately 9, Inter Semibold.
- Distribute items across the available width.

### Active Home State

- Dark icon and label.
- Rounded translucent dark background.
- Short dark indicator line above the Home item.

### Inactive State

- Muted icons and labels.
- No active background or top indicator.

Keep the navigation visible while content scrolls.

Use bottom safe-area handling so the system home indicator does not overlap the controls.

## Demo Data Organization

Keep fixture data separate from widget layout.

Suggested file:

`lib/features/home/presentation/demo/home_demo_data.dart`

Store:

- Student greeting and avatar initial.
- Notification count.
- Reference date.
- Next class.
- Suggested questions.
- Quick Actions.
- Deadlines.
- Announcements.

Use simple immutable models or typed constants.

Do not add Dio clients, API repositories, tokens, or persistent storage for this design-only task.

Keep demo content clearly identified in source code and the decision log. Do not add a large demo banner that changes the Figma composition.

## Interaction Behavior

All buttons should provide normal touch feedback.

For features outside this task:

- Use callbacks.
- Show a short SnackBar such as:
  `Schedule is not implemented yet.`
- Keep the Home screen visible.
- Do not build placeholder destination screens.
- Do not mark another bottom tab selected while still showing Home.
- Do not launch external navigation, request permissions, or call APIs.

Apply this behavior to:

- Notification bell.
- View Class and Navigate.
- AI suggestions and Ask AI Assistant.
- Quick Actions.
- Deadline and announcement rows.
- See all.
- Unimplemented bottom tabs.

Home remains selected by default.

## Routing and Preview

- Add the Home screen to the existing router.
- Use the existing `/home` route if available.
- Do not create a second MaterialApp.
- Preserve existing loading and login behavior.
- Do not turn the Login button into fake successful authentication.

If authentication is not implemented, provide a development-only preview entry point or documented debug launch option for Home.

Any preview bypass must remain isolated from production authentication rules.

## Suggested Widget Structure

Suggested files:

- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/home/presentation/widgets/home_header.dart`
- `lib/features/home/presentation/widgets/next_class_card.dart`
- `lib/features/home/presentation/widgets/ai_assistant_card.dart`
- `lib/features/home/presentation/widgets/quick_actions_grid.dart`
- `lib/features/home/presentation/widgets/deadline_card.dart`
- `lib/features/home/presentation/widgets/announcements_section.dart`
- `lib/features/home/presentation/demo/home_demo_data.dart`

Place the bottom navigation in the existing shared app-shell location if one exists.

Extract shared widgets where useful without creating unnecessary abstraction layers.

## Assets

- Reuse matching local icons and fonts.
- Otherwise export the actual Figma assets.
- Preserve the decorative header artwork.
- Download assets locally and register them in `pubspec.yaml`.
- Do not use temporary Figma asset URLs at runtime.
- Preserve icon proportions and stroke appearance.
- Do not replace the student initial avatar with `rangsitlogo.png`.
- Do not insert additional branding absent from this frame.

## Responsive Behavior

- Match the reference composition at 402 × 874.
- Support smaller and larger phones.
- Allow the entire content to scroll.
- Keep the final announcement reachable above bottom navigation.
- Avoid fixed card heights that clip text.
- Use wrapping for chips where needed.
- Preserve readable labels and accessible touch targets.
- Account for top and bottom system insets once.
- Avoid unnecessary animations or loading states for static demo data.

## Validation

Run:

    dart format .
    flutter analyze
    flutter test

Update affected tests and add focused checks for:

- Main sections rendering.
- Seven Quick Action tiles.
- Five bottom navigation items.
- Home selected initially.
- Scrolling to Announcements.
- Placeholder tap feedback without navigation or API requests.

Visually verify:

- Header and decorative artwork.
- Card order, spacing, colors, and typography.
- Next Class and AI cards.
- Full Quick Actions grid.
- Deadline and announcement content below the fold.
- Fixed bottom navigation.
- Small-screen and large-text behavior.
- No asset-loading errors or overflow.

Compare both the initial viewport and scrolled content against Figma.
Report Android and iOS verification separately.

## Changes and Decision Log

Update:

`spec-md/00-changes-decision.md`

Record:

- Date and sequential decision ID.
- Figma frame and node `3:209`.
- Files changed.
- Reused and exported assets.
- Demo-data approach.
- Preview-routing approach.
- Temporary button behavior.
- Validation results.
- Any necessary responsive deviations.

## Acceptance Criteria

- The Home screen matches Figma node `3:209`.
- All sections, including below-the-fold content, are implemented.
- Static fixture data matches the design.
- Bottom navigation remains fixed with Home selected.
- Interactions provide honest local feedback.
- No backend integration or fake authentication is introduced.
- Loading and login behavior remains intact.
- Relevant checks pass.
- The changes and decision log is updated.
## Temporary Static Login — Development Only

### Objective

Allow navigation from Login to Home using fixed demo credentials.
No API calls or backend authentication are required in this phase.

### Demo Credentials

- Email: `6708457@rsu.ac.th`
- Password: `P@ssw0rd`

These values are demo credentials only and must never be reused for a real account.

### Login Behavior

1. Validate the existing email and password fields.
2. Trim surrounding whitespace from the email and compare it case-insensitively.
3. Compare the password exactly. Do not trim or modify it.
4. If both values match, replace the Login route with `/home`.
5. If either value is incorrect:
    - Stay on Login.
    - Display `Invalid email or password.`
    - Allow the user to correct the inputs and retry.
6. Prevent duplicate navigation from repeated taps.

Replace the previous `Sign-in is not connected yet.` action with this temporary credential check.

Preserve the existing Figma login design.

### Application Flow

Loading Screen → Login Screen → Static Credential Check → Home Screen

- Keep the existing loading-screen completion behavior.
- After successful demo login, Back must not reopen Login or Loading.
- Use the existing router without creating another MaterialApp.
- Do not introduce artificial network delays.

### Session Rules

- Store demo login state in memory only.
- Do not generate or store JWTs, refresh tokens, or passwords.
- Do not use secure storage or shared preferences for this demo session.
- A fresh application launch requires login again.
- “Keep me signed in” remains a local checkbox interaction; persistence is not implemented.
- If logout already exists, clear demo state and return to Login.

### Implementation Boundary

- Keep static credential validation in a small, separate demo-auth controller or service.
- Activate it only through an explicit development/demo configuration.
- Do not weaken existing production authentication guards.
- Remove or disable this demo path when real authentication is integrated.
- Do not log entered credentials.

The Home screen continues to use its static Figma fixture data.
This login does not retrieve a real student profile.

### Validation

Verify:

- Correct credentials navigate to Home.
- Incorrect email or password displays the error.
- Empty fields show validation messages.
- Password visibility continues to work.
- Repeated taps do not create duplicate routes.
- Back does not reopen Login after success.
- A fresh launch returns through Loading to Login.
- No API requests occur.

### Decision Log

Update `spec-md/00-changes-decision.md` to record:

- The temporary development-only static login.
- Its replacement of the previous no-navigation login behavior.
- In-memory session handling.
- Files changed and checks performed.
- Planned replacement with backend authentication.

Do not copy the demo password or entered credentials into the decision log.