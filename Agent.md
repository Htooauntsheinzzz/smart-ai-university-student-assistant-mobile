# Agent.md — Smart AI University Student Assistant Mobile

## Project Overview

Develop a student mobile application using Flutter and Dart.

The application connects to the existing Spring Boot backend for student authentication, academic information, schedules, and AI assistant chat.

## Figma Design Reference

Implement the mobile screens using this Figma Design file:

https://www.figma.com/design/RUhIF3MsPa9jTWfT0Dou02/Smart-Ai-University-Mobile?node-id=0-1&m=dev

- File key: `RUhIF3MsPa9jTWfT0Dou02`
- Starting node: `0:1`
- Inspect the actual screen frames before implementation.
- Follow the design’s layout, colors, typography, spacing, icons, and assets.
- Preserve the designed navigation and screen hierarchy.
- Do not redesign screens or introduce unnecessary UI elements.
- If the design cannot be accessed, request screenshots or exported frames before implementing the affected screen.
- Implement screens with Flutter widgets, not embedded screenshots or web pages.

## Technology Stack

- Flutter stable with its bundled Dart SDK.
- Material 3 with a custom theme matching Figma.
- `flutter_riverpod` for state management and dependency injection.
- `go_router` for navigation and authentication redirects.
- `dio` for HTTP requests and interceptors.
- `flutter_secure_storage` for persisted authentication tokens.
- `shared_preferences` for non-sensitive preferences.
- `json_annotation` and `json_serializable` for API models.
- `build_runner` for code generation.
- Flutter `Form` and `TextFormField` for form validation.

Inspect existing dependencies and SDK compatibility before installing packages. Reuse existing suitable packages and components.

## Project Structure

Use a feature-based structure:

lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
├── core/
│   ├── config/
│   ├── network/
│   ├── storage/
│   ├── errors/
│   └── widgets/
└── features/
    ├── auth/
    ├── home/
    ├── academic/
    ├── schedule/
    ├── assistant/
    ├── profile/
    └── settings/

Within each feature:

- `data/`: API services, repositories, and models.
- `presentation/`: screens, widgets, controllers, and providers.

Keep API requests and business logic outside screen widgets.

## Specification Files

Store module and feature specifications inside `spec-md/`.

Before implementing a feature:

1. Read this file.
2. Read the relevant specification in `spec-md/`.
3. Inspect the existing project implementation.
4. Inspect the corresponding Figma screen.
5. Confirm the required backend API contract.
6. Implement only the requested scope.

Do not implement every module automatically.

## Backend Integration Rules

The backend already exists and must remain unchanged.

- Modify Flutter application files only.
- Do not change Spring Boot code, database schemas, migrations, Redis configuration, or admin web code.
- Use existing student APIs.
- Verify endpoint paths, request fields, response envelopes, status codes, and error formats before integration.
- Read backend documentation or source code when available.
- Do not invent endpoints or response fields.
- Report missing backend capabilities clearly.
- Never silently substitute mock data when a real request fails.
- Keep fixture-backed UI explicitly identified during development.

### Planned Academic Endpoints

Verify these against the current backend before use:

- `GET /api/v1/student/academic/profile`
- `GET /api/v1/student/academic/enrollments`
- `GET /api/v1/student/academic/courses`
- `GET /api/v1/student/academic/schedule`
- `GET /api/v1/student/academic/lecturers`
- `POST /api/v1/student/assistant/chat`

Authentication endpoint paths and DTOs must be discovered from the existing backend.

## Authentication Rules

- Identify the student through the JWT access token.
- Attach the access token to protected backend requests.
- Do not send arbitrary student IDs to retrieve another student’s information.
- Persist tokens using secure storage when required by the session contract.
- Never store passwords.
- Implement refresh-token behavior only if the backend supports it.
- Coordinate concurrent refresh requests and prevent retry loops.
- Distinguish expired sessions from network failures.
- Clear tokens, student caches, chat state, and protected navigation on logout.
- Prevent previous-account data from appearing after account switching.
- Follow the existing registration rule requiring an `rsu.ac.th` email address, with server validation authoritative.

## API Configuration

- Use a shared Dio client.
- Configure the backend base URL through environment-specific configuration such as `--dart-define`.
- Do not hardcode development addresses throughout the application.
- Use HTTPS for deployed environments.
- Configure finite request timeouts.
- Handle network, validation, authorization, and server errors consistently.
- Do not globally disable certificate validation.
- Do not log passwords, tokens, or private student payloads.

## AI Assistant Rules

- Flutter communicates with the Spring Boot assistant endpoint.
- Gemini calls and academic tool calling remain on the backend.
- Never include Gemini API keys or RS256 private keys in Flutter.
- Confirm the actual chat request and response contract.
- Do not assume streaming, conversation history, attachments, or voice support.

The planned minimal request is:

    {
      "message": "What classes do I have tomorrow?"
    }

- Prevent empty messages and duplicate submissions.
- Display sending, success, failure, and retry states.
- Preserve failed messages for intentional retry.
- Handle keyboard visibility and message-list scrolling.
- Do not invent academic facts or simulate successful backend answers.
- Clear private conversation state on logout.

## UI Implementation Rules

- Match inspected Figma screens using reusable Flutter components.
- Centralize colors, typography, spacing, and component styles.
- Bundle required static assets locally.
- Use responsive constraints, `SafeArea`, and keyboard-aware layouts.
- Support long text and accessibility text scaling.
- Avoid fixed dimensions that cause clipping or overflow.
- Implement loading, empty, error, retry, success, and disabled states.
- Make every visible action functional or report the missing capability.
- Add optional features only when requested and supported.

## Code Quality

- Use Dart null safety and typed models.
- Use `lower_snake_case` for Dart filenames.
- Prefer immutable state and `const` widgets where appropriate.
- Reuse existing components before creating alternatives.
- Dispose controllers and subscriptions.
- Cancel obsolete requests when appropriate.
- Avoid unrelated refactoring.
- Preserve existing working behavior.

## Validation

After implementation, run:

    dart format .
    flutter analyze
    flutter test

Also:

- Update starter tests when replacing the default Flutter application.
- Test meaningful authentication, parsing, navigation, and failure behavior.
- Run the requested screens on an emulator or physical device.
- Compare implemented screens with the inspected Figma reference.
- Check keyboard behavior, scrolling, back navigation, and session expiry.
- Report Android and iOS verification separately.
- Do not claim checks or device testing that were not performed.

## Completion Report

For each completed task, report:

1. Implemented screens and features.
2. Files changed.
3. Backend APIs connected.
4. Validation performed.
5. Remaining blockers or unsupported capabilities.


## Changes and Decision Log

Maintain `spec-md/00-changes-decision.md` as the project's implementation change and decision log.

### Rules

- Read this file before starting a task to understand previous decisions.
- Create it if it does not exist.
- Update it whenever a meaningful implementation change or technical decision is made.
- Record changes to architecture, dependencies, navigation, UI behavior, API integration, authentication, or project configuration.
- Explain what changed, why it changed, and which files or modules are affected.
- Distinguish implemented changes from proposed decisions and unresolved blockers.
- Record deviations from the specifications or Figma design, including their reason and approval when applicable.
- Do not treat a log entry as permission to change the backend or override project requirements.
- Append new entries in chronological order. Preserve previous entries.
- If a decision is replaced, add a new entry referencing the earlier decision.
- Never include passwords, tokens, API keys, or private student data.

### Entry Format

Use the following format for each entry:

### DEC-001 — Short Change or Decision Title

- **Date:** YYYY-MM-DD
- **Status:** Proposed / Accepted / Implemented / Blocked / Superseded
- **Module:** Affected feature or module
- **Context:** Problem or requirement that prompted the change
- **Decision:** Chosen approach
- **Reason:** Why this approach was selected
- **Changes:** Concrete implementation changes, or "Not implemented yet"
- **Affected files:** Relevant file paths
- **Validation:** Checks performed and their results, or "Not run"
- **Follow-up:** Remaining work, blockers, or superseded decision reference

Use sequential identifiers: DEC-001, DEC-002, DEC-003.

### Task Completion

Before reporting a task as complete, update
`spec-md/00-changes-decision.md` with any meaningful changes,
decisions, validation results, and remaining blockers.