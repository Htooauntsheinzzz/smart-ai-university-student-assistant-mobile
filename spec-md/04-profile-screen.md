# 04 — Profile Screen Design Implementation

## Objective

Implement the Flutter Profile screen matching Figma.

Use static demo data and local UI interactions only.
Connect the Profile tab to this screen and support local logout from the existing demo session.

No backend or API integration is required.

## Required Reading

Read before implementation:

- `Agent.md`
- `spec-md/00-changes-decision.md`
- Existing Home-screen specification.
- Existing static-login implementation.
- Existing theme and shared bottom navigation.

Preserve the working loading, login, and Home screens.

## Figma Reference

https://www.figma.com/design/RUhIF3MsPa9jTWfT0Dou02/Smart-Ai-University-Mobile?node-id=28-30&m=dev

- File key: `RUhIF3MsPa9jTWfT0Dou02`
- Frame: `Profile Screen`
- Node ID: `28:30`
- Reference viewport: `402 × 874`

Use this exact frame as the primary reference.

Inspect its screenshot and design context before implementation.
Do not mix in changes from `Profile Screen 2` without checking their purpose.

Use native Flutter widgets and responsive constraints.

## Scope

Implement these sections:

1. Page heading and settings icon.
2. Student avatar and identity.
3. Academic summary statistics.
4. Edit Profile button.
5. Student Information card.
6. Academic menu.
7. Account menu.
8. App menu.
9. Logout button and version footer.
10. Shared bottom navigation with Profile selected.

Include all below-the-fold content in a scrollable page.

Do not implement:

- Profile APIs.
- Profile editing forms.
- Avatar upload.
- Real password changes.
- Notification permission requests.
- Settings, Help, or About destination screens.
- Academic calculations.
- Backend changes.

## Design Tokens

Reuse existing matching theme tokens.

| Usage | Value |
|---|---|
| Page background | `#F3F6FA` |
| Dark header | `#273238` |
| Card background | `#FFFFFF` |
| Primary text | `#273238` |
| Section-heading text | `#66788A` |
| Muted labels and subtitles | `#8797A8` |
| Card border | `#E2E8EE` |
| Bottom navigation border | `#DFE5EB` |
| Row divider | `#F3F6FA` |
| Blue accent | `#01A2E5` |
| Green accent | `#16A34A` |
| Purple accent | `#8B5CF6` |
| Pink accent | `#D80255` |
| Amber accent | `#F59E0B` |
| Logout text | `#DC2626` |
| Logout background | `#FEF2F2` |
| Version footer | `#AAB6C2` |

Reference card shadow:

- Dark color at 4%, offset approximately (0, 1), blur 2.
- Dark color at 5%, offset approximately (0, 4), blur 12.

## Typography

Use Poppins and Inter consistently with the existing screens.

| Element | Font | Size / weight |
|---|---|---|
| My Profile | Poppins | 22, Black |
| Avatar initial | Poppins | 36, Black |
| Student name | Poppins | 20, Black |
| Student ID | Inter | 13, Semibold |
| Statistic values | Inter | 20, Black |
| Statistic labels | Inter | 9, Semibold |
| Section headings | Inter | 10, Bold |
| Information labels | Inter | 11, Semibold |
| Information values | Inter | 11, Bold |
| Menu titles | Inter | 13, Bold |
| Menu subtitles | Inter | 11, Regular |
| Edit Profile | Inter | 12, Regular |
| Logout | Inter | 14, Regular |
| Version footer | Inter | 10, Medium |
| Bottom navigation labels | Inter | 9, Semibold |

Section headings use uppercase text and approximately 1 letter spacing.

Use the actual font weights rather than simulated bold.

## 1. Header and Page Heading

Reference header node: `28:37`.

### Layout

- Dark full-width background.
- Reference height: approximately 477.5.
- Preserve the subtle circular decorative artwork.
- Horizontal padding: approximately 20.
- Heading row starts around y = 74 in the reference frame.
- Account for the actual top safe area without duplicating the inset.

### Heading

Display:

`STUDENT PORTAL`

Then:

`My Profile`

The small portal label uses:

- Inter Bold.
- Size 9.
- White at approximately 50% opacity.
- Letter spacing approximately 0.9.

### Settings Button

Place a settings icon button at the upper-right.

- Visible container: approximately 42 × 42.
- Radius: 16.
- Translucent white background.
- Thin translucent white border.
- Icon: approximately 19.

Provide an accessible touch area and a “Settings” semantic label.

## 2. Avatar and Student Identity

### Avatar

- Centered rounded square.
- Size: approximately 96 × 96.
- Radius: 24.
- White fill at approximately 20% opacity.
- White border at approximately 40% opacity.
- Border width: 2.
- Subtle shadow.
- White centered initial: `S`.

Add the green circular check badge overlapping the lower-right corner:

- Size: approximately 24.
- Blue border.
- Small white check icon.

Use the initial avatar shown in Figma.
Do not replace it with `assets/images/rangsitlogo.png`.

### Identity Text

Figma reference values:

- Name: `Shein`
- Student ID: `ID: 6512345678`

Use approximately 16 spacing below the avatar before the name.
Place the ID below the name with a small gap.

The displayed Figma ID is a fixture. It does not need to match the
temporary login email `6708457@rsu.ac.th`.

Keep these concepts separate:
- Demo login credentials control local access.
- Profile fixtures reproduce the inspected design.

Do not change the static login credentials in this task.

## 3. Academic Summary Statistics

Place three compact statistic cards horizontally below the identity.

| Value | Label |
|---|---|
| 3.42 | CGPA |
| 87 | CREDITS |
| 5 | COURSES |

### Styling

- White background at approximately 15% opacity.
- White border at approximately 20% opacity.
- Radius: 16.
- Horizontal gap: approximately 12.
- Inner padding: approximately 20 horizontally and 12 vertically.
- White values.
- Labels in white at approximately 60% opacity.
- Top spacing: approximately 16.

Keep values static. Do not calculate GPA, credits, or course counts.

Allow the layout to adapt if larger text does not fit.

## 4. Edit Profile Button

Place below the statistics.

Display:

`Edit Profile`

Appearance:

- White background.
- Dark text.
- Pencil icon.
- Radius: 16.
- Reference visual height: approximately 40.
- Horizontal padding: approximately 20.
- Icon size: approximately 13.
- Icon/text gap: approximately 8.
- Top spacing: approximately 16.

Keep an accessible touch area.

On tap, show:

`Profile editing is not implemented yet.`

Do not create an editing form or modify the demo profile.

## 5. Student Information

Reference section node: `28:99`.

Heading:

`STUDENT INFORMATION`

### Container

- Horizontal page margin: 16.
- Top section spacing: 20.
- Gap between heading and card: 12.
- White background.
- Radius: 24.
- Thin border and subtle shadow.

### Rows

Preserve this order and fixture content:

| Label | Value |
|---|---|
| Major | Computer Science |
| Academic Year | Year 3 |
| Faculty | Faculty of Information Technology |
| Department | Computer Science |
| Program | Bachelor of Science |
| Semester | Semester 1 / 2026 |
| Email | 6512345678@rsu.ac.th |

### Row Appearance

- Minimum height: approximately 52.
- Horizontal padding: 16.
- Icon container: 32 × 32.
- Icon-container radius: 12.
- Icon-container background: page background.
- Icon size: approximately 16.
- Gap between elements: approximately 12.
- Label on the left.
- Value right-aligned.
- Thin dividers between rows.

Allow the Faculty value to wrap as shown in Figma.

Do not force fixed row heights when text wraps.
Ensure the email remains readable on narrow screens.

These are display-only rows, not editable input fields.

## 6. Academic Menu

Heading:

`ACADEMIC`

Show one menu row:

- Title: `My Courses`
- Subtitle: `5 enrolled this semester`
- Blue-tinted icon container.
- Right chevron.

Container styling:

- White background.
- Radius: 24.
- Thin border and subtle shadow.
- Menu row minimum height: approximately 60.
- Horizontal padding: 16.
- Leading icon container: 40 × 40, radius 16.
- Icon size: approximately 19.
- Right chevron: approximately 14.

On tap, show:

`My Courses is not implemented yet.`

Do not create the course screen in this task.

## 7. Account Menu

Heading:

`ACCOUNT`

Use one grouped card with three rows:

| Title | Subtitle | Accent |
|---|---|---|
| Personal Information | Edit your profile details | Purple |
| Notification Preferences | Manage alerts & reminders | Pink |
| Change Password | Update your password | Amber |

### Styling

- White grouped card.
- Radius: 24.
- Thin border and subtle shadow.
- Minimum row height: approximately 60.
- Light separators.
- Leading tinted icon container: 40 × 40.
- Icon container radius: 16.
- Main title above subtitle.
- Chevron on the right.
- Icon backgrounds use their accent color at approximately 9% opacity.

### Interactions

Show short placeholder feedback:

- Personal Information:
  `Profile editing is not implemented yet.`
- Notification Preferences:
  `Notification preferences are not implemented yet.`
- Change Password:
  `Password changes are not implemented yet.`

Do not open forms, request permissions, or persist settings.

## 8. App Menu

Heading:

`APP`

Use one grouped card with these rows:

| Title | Subtitle | Accent |
|---|---|---|
| Settings | App preferences | Muted gray |
| Help | Get support | Green |
| About | SMART AI v2.0.1 | Dark gray |

Match the Account menu’s card and row styling.

Keep `SMART AI v2.0.1` as the Figma preview text.
It is not a claim about the actual build version.

The header settings icon and the Settings row should use the same callback.

For each action, display a short “not implemented yet” SnackBar.
Do not create additional destination screens.

## 9. Logout and Version Footer

### Logout Button

Display:

`Logout`

Appearance:

- Full content width.
- Horizontal page margin: 16.
- Top spacing: approximately 20.
- Height: at least 52.
- Radius: 16.
- Pale red background: `#FEF2F2`.
- Subtle pale-red border.
- Red logout icon, approximately 16.
- Red label.
- Icon/text gap: approximately 8.

### Local Logout Behavior

Reuse the existing demo-auth controller/service.

On tap:

1. Clear the in-memory demo login state.
2. Reset any student-specific local UI state.
3. Return to `/login`.
4. Clear the protected navigation stack.
5. Ensure Back cannot reopen Home or Profile.

Do not call an API or create token-storage logic.

### Footer

Below the button, centered:

`SMART AI University Assistant v2.0.1`

- Top spacing: approximately 12.
- Inter Medium.
- Size: 10.
- Color: `#AAB6C2`.

Allow bottom clearance above the fixed navigation.

## 10. Bottom Navigation

Reuse the existing shared Home navigation.

Items remain:

1. Home
2. AI Chat
3. Schedule
4. Campus
5. Profile

### Selected State

When this screen is visible:

- Profile is selected.
- Profile icon and label use the dark primary color.
- Show the rounded translucent active background.
- Show the short dark indicator line above Profile.
- Home uses its inactive appearance.

Reference sizes:

- Icons: approximately 22.
- Labels: 9.
- Active indicator: approximately 24 × 2.
- Active background radius: 16.

### Navigation Behavior

- Tapping Profile from Home opens Profile.
- Tapping Home returns to the implemented Home screen.
- Tapping the current tab does not push another copy.
- Preserve scroll position where the existing app shell supports it.
- Keep navigation fixed while Profile content scrolls.
- Use one shared navigation bar, not nested duplicate bars.

For other tabs without implemented screens, retain the existing
placeholder feedback and do not change selection while Profile remains visible.

## Demo Data

Suggested file:

`lib/features/profile/presentation/demo/profile_demo_data.dart`

Use a typed immutable fixture for:

- Name and avatar initial.
- Student ID.
- GPA.
- Credits and course count.
- Student Information values.
- Display version strings.

Keep fixture data separate from widget layout.

Do not add Dio services, API repositories, or database access.
Do not duplicate the static login password in profile files.

## Suggested Components

Follow existing project conventions.

Suggested files:

- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/features/profile/presentation/widgets/profile_header.dart`
- `lib/features/profile/presentation/widgets/profile_stat_card.dart`
- `lib/features/profile/presentation/widgets/student_information_card.dart`
- `lib/features/profile/presentation/widgets/profile_menu_group.dart`
- `lib/features/profile/presentation/widgets/profile_menu_tile.dart`
- `lib/features/profile/presentation/widgets/profile_logout_section.dart`
- `lib/features/profile/presentation/demo/profile_demo_data.dart`

Reuse shared theme tokens, navigation, icons, and card components where appropriate.

Do not introduce another MaterialApp or state-management framework.

## Assets

- Reuse exact matching local assets where available.
- Otherwise download/export the Figma icons and decorative artwork.
- Store assets locally and register them in `pubspec.yaml`.
- Preserve original proportions and stroke appearance.
- Do not use temporary Figma asset URLs at runtime.
- Reuse existing Poppins and Inter font configuration.
- Do not replace the decorative artwork with unrelated illustrations.

## Responsive Layout

- Match the reference composition at 402 × 874.
- Use one vertical scroll area for header and content.
- Keep bottom navigation outside that scroll area.
- Do not copy the Figma container’s clipping as a fixed screen-height limitation.
- Make Student Information, Academic, Account, App, and Logout fully reachable.
- Use SafeArea/insets without adding duplicate top or bottom padding.
- Allow long values and large text to wrap.
- Expand cards and rows rather than clipping text.
- Avoid horizontal overflow in the three statistics cards.
- Preserve readable spacing on smaller Android phones.

## Validation

Run:

    dart format .
    flutter analyze
    flutter test

Verify:

- Home → Profile navigation works.
- Profile → Home navigation works.
- Correct bottom navigation item is selected.
- Repeated tab taps do not create duplicate routes.
- All seven Student Information rows render.
- All menu groups are reachable by scrolling.
- Placeholder actions show feedback.
- Logout clears demo state and returns to Login.
- Back cannot reopen protected screens after logout.
- Existing static login still works.
- No API requests occur.
- No overflow appears with long text or larger text settings.

Compare screenshots of both the initial viewport and lower sections against Figma.

Report real Android device and iOS simulator validation separately.
Only claim checks that were actually performed.

## Changes and Decision Log

Append an entry to:

`spec-md/00-changes-decision.md`

Record:

- Date and sequential decision ID.
- Figma frame `Profile Screen`, node `28:30`.
- Files changed.
- Shared components reused.
- Asset and typography decisions.
- Static profile fixture values.
- The distinction between Figma profile fixtures and demo-login identity.
- Home/Profile navigation behavior.
- Local logout implementation.
- Validation results and remaining work.

Never include passwords or tokens in the decision log.

## Acceptance Criteria

- Profile matches the inspected Figma frame.
- All sections, including Logout, are implemented and scrollable.
- Profile is reachable from the existing Home navigation.
- Home and Profile share one consistent bottom navigation.
- Static demo login remains working.
- Logout works locally without an API.
- Other actions provide honest placeholder feedback.
- No backend changes or real account updates occur.
- Relevant checks pass.
- The decision log is updated.