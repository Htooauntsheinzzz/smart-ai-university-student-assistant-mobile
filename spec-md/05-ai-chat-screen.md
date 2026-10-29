# 05 — AI Chat Screen Design Implementation

## Objective

Implement the Flutter AI Chat screen matching Figma.

This phase includes the screen design, navigation, text input,
suggested prompts, and local demo interactions.

Do not connect the backend or Gemini API yet.

## Required Reading

Read before implementation:

- `Agent.md`
- `spec-md/00-changes-decision.md`
- Existing Home and Profile specifications.
- Existing static-login implementation.
- Shared app shell, theme, and bottom navigation.

Preserve working loading, login, Home, and Profile behavior.

## Figma Reference

https://www.figma.com/design/RUhIF3MsPa9jTWfT0Dou02/Smart-Ai-University-Mobile?node-id=33-30&m=dev

- File key: `RUhIF3MsPa9jTWfT0Dou02`
- Frame: `Ai-Chat Screen`
- Node ID: `33:30`
- Reference viewport: `402 × 874`

Inspect this exact frame and its screenshot before implementation.

Use native Flutter widgets. Adapt the layout responsively rather
than copying generated React code or fixed screen coordinates.

## Scope

Implement:

1. Dark AI Assistant header.
2. History icon and New Chat button.
3. Horizontally scrolling suggested prompts.
4. Scrollable conversation area.
5. Initial assistant greeting.
6. Message composer.
7. Attachment and Send controls.
8. Shared bottom navigation with AI Chat selected.
9. Navigation from Home AI actions.
10. In-memory demo conversation behavior.

Do not implement:

- Backend requests.
- Gemini SDK or API calls.
- Real academic answers.
- Streaming responses.
- Persistent conversation history.
- File selection or upload.
- Voice recording.
- Database or backend changes.

## Design Tokens

Reuse existing matching theme tokens.

| Element | Value |
|---|---|
| Page/conversation background | `#F3F6FA` |
| Header background | `#273238` |
| White surfaces | `#FFFFFF` |
| Primary text | `#273238` |
| Suggested-prompt text | `#44545F` |
| Secondary text | `#8797A8` |
| Borders | `#DFE5EB` |
| Assistant accent | `#01A2E5` |
| Status dot | `#16A34A` |
| Disabled Send background | `#DFE5EB` |

Use Poppins Bold for the header title and Inter for other text.

| Text | Reference style |
|---|---|
| AI Assistant | Poppins Bold, 17 |
| Status | Inter Medium, 10 |
| New Chat | Inter Bold, 10 |
| SUGGESTED | Inter Semibold, 10 |
| Prompt chips | Inter Regular, 10 |
| Assistant message | Inter Regular, 12 |
| Message timestamp | Inter Regular, 9 |
| Composer text | Inter Regular, 13 |
| Bottom-navigation labels | Inter Semibold, 9 |

## Overall Layout

Use the existing app shell with:

- Header at the top.
- Suggested-prompt strip below the header.
- Expanded, vertically scrollable conversation area.
- Composer anchored below the conversation.
- Shared bottom navigation at the bottom.

Only the conversation scrolls vertically.
The header and composer must not scroll away with messages.

The suggestion strip scrolls horizontally.

Do not wrap the entire screen in one vertical SingleChildScrollView.

## 1. AI Assistant Header

Reference node: `33:36`.

### Appearance

- Dark background.
- Preserve the subtle decorative circular artwork.
- Reference total height: approximately 130.
- Reference content row begins around y = 70.
- Horizontal padding: 20.
- Bottom spacing: approximately 16.

Handle the actual device safe area without adding the reference
top inset twice.

### Leading Assistant Icon

- Container: approximately 44 × 44.
- Radius: 16.
- Translucent white background.
- Thin translucent white border.
- Robot icon: approximately 20.
- Match the actual Figma icon.

### Title and Status

Display:

`AI Assistant`

Below it:

`Online · Ready to help`

Place a green status dot before the status text:

- Dot size: approximately 8.
- Gap: approximately 6.
- Status text: white at approximately 70% opacity.

The status is a static Figma preview label in this phase.
Do not implement a fake connection-health check or claim a live AI connection.

### History Button

- Clock/history icon.
- Visible container: approximately 36 × 36.
- Radius: 16.
- Translucent white background and border.
- Icon size: approximately 16.
- Accessible label: `Chat history`.

On tap, show:

`Chat history is not available in this demo.`

Do not build a history screen.

### New Chat Button

Display a plus icon followed by:

`New Chat`

- Reference height: approximately 36.
- Horizontal padding: approximately 12.
- Radius: 16.
- Translucent white background and border.
- White label.

Provide accessible touch areas for both header buttons.

## 2. Suggested Prompts

Reference node: `33:72`.

### Strip Appearance

- White background.
- Bottom border.
- Vertical padding: approximately 10.
- Heading horizontal padding: 16.
- Heading: `SUGGESTED`.
- Gap below heading: approximately 8.

### Chips

Display all five prompts in this order:

1. `What classes do I have today?`
2. `Where is Building 11?`
3. `What assignments are due this week?`
4. `When is my next exam?`
5. `Take me to my next class`

Each chip includes its matching Figma icon.

Reference styling:

- White background.
- Thin border.
- Pill-shaped corners.
- Height: approximately 34.
- Horizontal inner padding: approximately 10.
- Icon size: approximately 13.
- Icon/text gap: approximately 6.
- Gap between chips: 8.
- Strip horizontal padding: 16.

Use a horizontal ListView or equivalent.
Do not clip later prompts permanently or wrap them into multiple rows.

### Interaction

Tapping a prompt:

- Copies its exact text into the composer.
- Places the cursor at the end.
- Does not send automatically.
- Allows editing before Send is pressed.

If a different non-empty draft already exists, preserve it and show
a brief message asking the user to clear or send it first.

These are local UI behaviors, not verified Figma prototype actions.

## 3. Conversation Area

Reference node: `33:121`.

### Layout

- Background: `#F3F6FA`.
- Padding: approximately 16.
- Message spacing: approximately 16.
- Expand to fill the space between suggestions and composer.
- Preserve the large empty area in the initial design.

Use a scrollable message list with stable message IDs.

Do not add extra welcome cards, illustrations, date dividers,
typing indicators, or sample academic conversations.

### Initial Assistant Message

Display exactly:

`Hi Shein! How can I help with your university life today?`

Reference timestamp:

`09:00 AM`

This is a fixed fixture for the initial design.

### Assistant Avatar

- Blue background: `#01A2E5`.
- Size: approximately 36 × 36.
- Radius: 16.
- White robot icon: approximately 17.
- Subtle blue shadow.
- Align near the top of the message.
- Gap before bubble: approximately 10.

### Assistant Bubble

- White background.
- Thin border.
- Subtle shadow.
- Padding: approximately 16 horizontal and 12 vertical.
- Top-left radius: 6.
- Other corners: 24.
- Reference width: approximately 303.
- Text line height: approximately 19.5.

Use a responsive maximum width rather than forcing this width
on every device.

Place the muted timestamp beneath the bubble with approximately
4 spacing and a small horizontal inset.

## 4. Message Composer

Reference node: `33:141`.

### Outer Area

- White background.
- Thin top border.
- Horizontal padding: 16.
- Top padding: approximately 10.
- Bottom padding: approximately 14.

### Input Container

- Background: `#F3F6FA`.
- Thin border.
- Radius: 24.
- Minimum height: approximately 50.
- Left padding: approximately 12.
- Right padding: approximately 8.
- Vertical padding: approximately 6.

Arrange:

Attachment button → Expanded text field → Send button

### Placeholder

Display exactly:

`Ask about your university…`

- Inter Regular, 13.
- Muted text color.
- No additional underline or default TextField border.

### Input Behavior

- Start with an empty draft.
- Support multiline text.
- Grow from one line to a bounded maximum, such as four lines.
- Scroll within the field beyond that limit.
- Keep Send visible.
- Do not submit when the user inserts a newline.
- Reject whitespace-only submissions.
- Dispose text and focus controllers correctly.

### Attachment Button

- Visible area: approximately 36 × 36.
- Paperclip icon: approximately 18.
- Match Figma styling.
- Accessible label: `Attach file`.

On tap, show:

`Attachments are not available in this demo.`

Do not request file, camera, microphone, or storage permissions.

### Send Button

- Visible size: approximately 38 × 38.
- Radius: 16.
- Send-arrow icon: approximately 15.
- Accessible label: `Send message`.

When the composer is empty:

- Disable the action.
- Match the gray disabled state shown in Figma.

When non-whitespace text exists:

- Enable the action.
- Reuse an established app accent treatment for the enabled state.
- Document the enabled styling as an added state because the
  inspected frame shows only the empty/disabled state.

## 5. Local Demo Sending

Implement a minimal local interaction so the screen can be tested.

On Send:

1. Read and validate the draft.
2. Append one user message to the in-memory conversation.
3. Clear the composer.
4. Scroll to the new message.
5. Show a SnackBar:

   `Demo mode: AI responses are not connected yet.`

Do not generate a fake academic answer, fake network delay,
or typing animation.

### User Message Styling

The inspected frame contains only an assistant greeting.

For local user messages, use a documented temporary style:

- Right-aligned.
- Dark background: `#273238`.
- White text.
- Padding consistent with the assistant bubble.
- Rounded corners with a smaller top-right corner.
- Responsive maximum width.
- A local timestamp below the bubble.

Treat this as an implementation addition, not an inspected
Figma message variant. Replace it if a dedicated variant is supplied.

Prevent repeated taps from adding duplicate copies of the same draft.

## 6. New Chat Behavior

New Chat resets the local conversation.

- Clear the composer.
- Remove locally added user messages.
- Restore the initial greeting and reference timestamp.
- Reset the message-list scroll position.
- Dismiss the keyboard.

If user messages or a draft exist, show a small confirmation dialog:

- Title: `Start a new chat?`
- Message: `This will clear the current demo conversation.`
- Actions: `Cancel` and `New Chat`

This dialog is an added local interaction, not part of the inspected frame.

If only the initial greeting exists and the draft is empty,
reset without a confirmation dialog.

## 7. Home Screen Integration

Replace the previous placeholder behavior for existing Home AI actions.

### Ask AI Assistant

- Open the AI Chat tab.
- Do not insert or send a message automatically.

### Home Suggested Questions

- Open AI Chat.
- Prefill the composer with the selected Home prompt.
- Do not send automatically.
- Preserve an existing non-empty draft rather than overwriting it.
- Consume the navigation intent once, not on every rebuild.

Do not change the Home screen’s appearance.

## 8. Bottom Navigation

Reuse the existing shared bottom navigation.

Keep the exact order:

1. Home
2. AI Chat
3. Schedule
4. Campus
5. Profile

### Selected State

AI Chat is selected while this screen is visible.

- Dark icon and label.
- Rounded translucent dark active background.
- Short dark indicator line above the item.
- Inactive items use muted colors.

Reference values:

- Icon size: approximately 22.
- Label size: 9.
- Indicator: approximately 24 × 2.
- Active radius: 16.

### Navigation

- Home opens the implemented Home screen.
- Profile opens the implemented Profile screen.
- AI Chat opens this screen.
- Repeated selection does not push duplicate routes.
- Preserve the local conversation and draft when switching tabs.
- Keep existing placeholder feedback for unimplemented tabs.
- Do not show a different selected tab while AI Chat remains visible.

Use one shared app shell and one bottom navigation bar.

## 9. Keyboard and Scrolling

- Keep the composer above the keyboard.
- Reduce the conversation area's available height when typing.
- Do not let the keyboard cover the input or Send button.
- Avoid applying keyboard insets twice.
- Hide the bottom tab bar while the keyboard is visible if needed
  to preserve usable space; restore it when the keyboard closes.
- Record this keyboard behavior as a responsive implementation decision.
- Android Back should dismiss the keyboard before leaving the screen.

Scrolling rules:

- Scroll to a newly sent user message.
- Keep the latest message reachable.
- Do not force scrolling during unrelated rebuilds.
- Preserve scroll position when switching tabs where practical.
- Long messages must wrap without horizontal overflow.

## 10. State and Session Rules

Use the existing Riverpod approach.

Suggested state:

- Immutable list of chat messages.
- Current draft or a coordinated text controller.
- Stable message IDs.
- Message role: assistant or user.
- Message text and timestamp.

Use in-memory state only.

- No database.
- No shared preferences.
- No token storage.
- No persistent history.
- No message-content logging.
- No API keys.

Clear conversation and draft state when the user logs out.
A new demo session starts with the initial greeting.

## Suggested Files

Follow existing project conventions.

- `lib/features/assistant/presentation/screens/ai_chat_screen.dart`
- `lib/features/assistant/presentation/widgets/ai_chat_header.dart`
- `lib/features/assistant/presentation/widgets/suggested_prompts_strip.dart`
- `lib/features/assistant/presentation/widgets/chat_message_bubble.dart`
- `lib/features/assistant/presentation/widgets/chat_composer.dart`
- `lib/features/assistant/presentation/controllers/demo_chat_controller.dart`
- `lib/features/assistant/presentation/models/chat_message.dart`
- `lib/features/assistant/presentation/demo/chat_demo_data.dart`

Reuse the existing theme and navigation.
Do not create another MaterialApp or introduce another state framework.

## Assets

- Reuse exact matching local icons and fonts.
- Otherwise export the actual Figma assets.
- Include the header decorative artwork.
- Store assets locally and register them in `pubspec.yaml`.
- Do not use temporary Figma URLs at runtime.
- Preserve icon proportions and stroke appearance.
- Reuse existing Inter and Poppins fonts.
- Do not substitute the university logo for the robot avatars.

## Validation

Run:

    dart format .
    flutter analyze
    flutter test

Verify:

- Initial screen matches Figma at 402 × 874.
- All five suggestions are reachable horizontally.
- Initial greeting and timestamp match the reference.
- Empty and whitespace-only drafts cannot be sent.
- Suggestions populate the composer without auto-sending.
- Existing drafts are not silently overwritten.
- Send adds one local user message and clears the field.
- No fake assistant answer or network request occurs.
- New Chat cancel/reset behavior works.
- History and attachment controls show honest feedback.
- Home AI actions open this screen correctly.
- Tab switching preserves local conversation and draft.
- Logout clears chat state.
- Keyboard does not cover the composer.
- Long text and smaller screens do not overflow.

Report Android-device and iOS-simulator verification separately.
Only claim checks actually performed.

## Changes and Decision Log

Update:

`spec-md/00-changes-decision.md`

Record:

- Date and sequential decision ID.
- Figma frame `Ai-Chat Screen`, node `33:30`.
- Files changed.
- Shared assets and widgets reused.
- Local-only conversation behavior.
- Added user-bubble and enabled-Send styles.
- New Chat confirmation behavior.
- Keyboard/navigation behavior.
- Home-to-chat integration.
- Validation results.
- Future backend integration work.

Do not record private message content, passwords, or tokens.

## Acceptance Criteria

- The initial AI Chat screen matches Figma node `33:30`.
- Suggested prompts, input, and local Send behavior work.
- Home, AI Chat, and Profile navigation work consistently.
- No backend or Gemini integration is introduced.
- No academic answers are fabricated.
- Chat state survives tab switching and clears on logout.
- The composer remains usable with the keyboard open.
- Relevant checks pass.
- The changes and decision log is updated.