# Student Login API Implementation

Suggested file: `spec-md/06-login-auth-api.md`

## 1. Objective

Connect the existing Flutter login screen to the backend student authentication API.

Replace the static credential check with real backend authentication while preserving the current Figma login design.

## 2. Scope

Implement:

- Student email and password validation.
- Backend login request.
- Loading, success, and error states.
- Secure session handling according to the backend contract.
- Authentication-aware navigation.
- Session restoration during the loading screen.
- Logout and session cleanup.
- Token refresh only if supported by the backend.

Do not redesign the loading, login, Home, Profile, or AI Chat screens.

## 3. Inspect the Existing Projects First

Read:

- `Agent.md`
- `spec-md/00-changes-decision.md`
- Existing loading and login specifications.
- Existing Flutter routing, authentication state, and networking code.
- Backend authentication controllers, request/response DTOs, security configuration, and API documentation.

Identify the exact student login contract before implementing requests.

Do not guess endpoint paths, JSON keys, token types, or error formats.

If the backend project or API documentation is unavailable, request its location or the relevant API contract. Complete independent Flutter preparation, but do not claim the integration is complete.

## 4. Backend Contract Checklist

Document the verified values below:

| Item | Required information |
|---|---|
| Base URL | Development and production server URLs |
| Login endpoint | HTTP method and exact path |
| Request body | Exact email and password field names |
| Successful response | Status code and response structure |
| Authentication mechanism | Bearer tokens, cookies, or another documented mechanism |
| Access token | Field name and expiration information, if applicable |
| Refresh token | Field name, rotation rules, and expiration, if supported |
| Current student | Login response fields or authenticated profile endpoint |
| Student access | How the backend identifies and authorizes students |
| Error response | Error codes, validation messages, and JSON structure |
| Refresh endpoint | Method, path, request, and response, if supported |
| Logout endpoint | Method, path, and revocation behavior, if supported |

Use sanitized examples without real passwords or tokens.

## 5. Remove Static Authentication

Remove the hardcoded email/password comparison and any demo-authentication bypass.

- Authenticate using the backend response.
- Never navigate to Home because credentials match a local constant.
- Never fall back to demo login when the backend is unavailable.
- Do not prefill or store the previous demo password.
- Remove obsolete demo-auth tests and replace them with relevant API-auth tests.

Keep unrelated screen fixtures until their corresponding backend integrations are implemented.

## 6. Configuration

Configure the API base URL through the project's existing environment configuration.

If no configuration exists, use a build-time value such as:

`--dart-define=API_BASE_URL=<backend-base-url>`

Requirements:

- Keep environment configuration separate from widgets.
- Fail clearly when the base URL is missing or invalid.
- Use HTTPS in production.
- Never include database credentials, signing keys, or backend secrets in the app.
- Do not disable certificate validation.

For local development:

- Android emulator: use the host address appropriate to the emulator.
- Physical Android/iOS device: use a reachable development-server address.
- USB debugging alone does not make the Mac's localhost available to the phone.
- Limit any necessary HTTP exceptions to development builds.

Record the actual tested development configuration.

## 7. Architecture

Reuse the existing project structure and dependencies.

Preferred responsibilities:

- **Dio client:** base URL, timeouts, request execution, authentication interceptor.
- **Auth repository:** login, refresh, session restoration, logout.
- **Auth controller/provider:** authentication state and UI actions.
- **Session storage:** secure persistence where required.
- **Router:** redirects based on authentication state.
- **Login screen:** input, validation, and state rendering.

Use Riverpod and go_router if already established in the project.

Do not perform HTTP requests directly inside widgets or introduce a second networking/state-management stack.

Suggested structure, adapted to existing conventions:

    lib/
      core/
        config/
          app_config.dart
        network/
          api_client.dart
        storage/
          session_storage.dart
      features/
        auth/
          data/
            auth_api.dart
            auth_repository_impl.dart
            models/
          domain/
            auth_repository.dart
          presentation/
            controllers/
              auth_controller.dart
            screens/
              login_screen.dart

Create only the files needed by the existing architecture.

## 8. Login Form Behavior

Preserve the existing Figma appearance.

### Student email

- Require a non-empty email.
- Trim surrounding whitespace.
- Validate basic email format.
- Apply case normalization or university-domain restrictions only when confirmed by the backend contract.

### Password

- Require a non-empty password.
- Preserve the exact entered value.
- Do not trim, lowercase, or transform it.
- Keep the visibility toggle.
- Do not impose signup password rules on login.

### Sign In

1. Validate the form.
2. Dismiss the keyboard.
3. Clear the previous request error.
4. Enter the submitting state.
5. Submit one login request.
6. Handle the verified response.
7. Update session state.
8. Navigate to Home only after successful authentication and required session setup.

While submitting:

- Disable duplicate submissions.
- Show progress inside the existing button without changing its dimensions.
- Prevent credentials from changing during the active request.

Do not automatically retry login requests.

## 9. Authentication State

Represent these states explicitly:

- Initializing/restoring session.
- Unauthenticated.
- Submitting login.
- Authenticated.
- Recoverable initialization failure, where applicable.

A login error should return the form to an interactive unauthenticated state with a user-facing message.

A late response must not restore a session after logout or after the operation has been cancelled.

## 10. Session Storage and “Keep Me Signed In”

Never persist the password.

If the backend uses tokens:

- Keep the access token in memory where practical.
- Use secure platform-backed storage for credentials that must survive an app restart.
- Never store tokens in plain preferences, application logs, or source code.

### Checkbox unchecked

- Keep the session in memory.
- Remove any previously persisted authentication session.
- A fresh app process should require login again.

### Checkbox checked

- Persist only the session material required by the verified backend contract.
- Prefer a refresh token when supported.
- Restore the session on the next launch.

If the backend does not support renewable sessions, document the actual expiry behavior. Do not invent a refresh flow.

If the required secure-storage operation fails, show a recoverable error and avoid leaving a partially initialized session.

## 11. Startup and Routing

Use the existing loading screen while checking session state.

### No persisted session

Navigate to Login.

### Valid restorable session

Validate or renew it according to the backend contract, then navigate to Home.

### Expired or revoked session

Clear stored authentication data and navigate to Login.

### Temporary network failure

Do not delete a potentially valid stored session solely because of a timeout or connection failure.

Show a retry path. Do not display authenticated content unless an explicit offline-access policy exists.

Routing requirements:

- Protect Home, Profile, AI Chat, and other authenticated routes.
- Prevent authenticated users from returning to Login through Back navigation.
- Prevent unauthenticated access through deep links.
- Avoid briefly rendering protected screens while session restoration is pending.
- Treat server authorization as authoritative; client route guards are only UI controls.

## 12. Authenticated Requests and Refresh

Implement this section only if supported by the verified token contract.

- Attach the access token only to requests for the trusted backend.
- Exclude login and refresh requests from recursive refresh handling.
- Handle protected-endpoint `401` responses through one coordinated refresh operation.
- Concurrent requests must share the same refresh operation.
- Save rotated refresh tokens securely.
- Retry an eligible failed request at most once after successful refresh.
- Do not blindly replay non-idempotent operations without a safe backend contract.
- If refresh is rejected, clear the session and return to Login.
- Do not log out automatically for every `403`; it may indicate insufficient permission.
- Do not treat a login `401` as a request to refresh.

Never ship JWT signing secrets in the Flutter app. The backend remains responsible for validating tokens and authorizing requests.

## 13. Errors

Map actual backend responses to clear messages.

| Condition | User-facing behavior |
|---|---|
| Missing/invalid input | Show field validation |
| Invalid credentials | “Invalid email or password.” |
| Student access denied | Show a safe backend-approved access message |
| Rate limit | Ask the user to wait; respect retry information when available |
| No connection | “Unable to connect. Check your connection and try again.” |
| Timeout | “The request timed out. Please try again.” |
| Server failure | “Unable to sign in right now. Please try again later.” |
| Malformed successful response | Show a general error and remain unauthenticated |

Requirements:

- Never display raw stack traces, SQL errors, or full response bodies.
- Never log passwords, tokens, or authorization headers.
- Preserve the email after a failed attempt.
- Keep errors accessible and visually consistent with the login screen.

## 14. Student Data

Use authenticated student data when supplied by the backend.

- Map identity fields from the verified response or student-profile endpoint.
- Distinguish the authentication email from unrelated demo screen fixtures.
- Do not show fixture profile details as if they were returned by the backend.
- Integrate only the identity fields required for this feature.
- Leave unrelated academic data integration for its own specification.

If the backend authenticates multiple roles, enforce the documented student-access flow. A local role check alone must not grant backend access.

## 15. Logout

Connect the existing Profile logout action to the real session lifecycle.

- Call the backend logout/revocation endpoint if one exists.
- Always clear local session state and secure credentials, even if that request fails.
- Clear user-specific cached data, AI Chat messages, and drafts.
- Cancel or invalidate pending authenticated work.
- Navigate to Login and clear the protected navigation stack.
- Prevent an in-flight refresh or login response from restoring the old session.

Do not claim server-side revocation succeeded when the request failed.

## 16. Validation

Run:

- `dart format .`
- `flutter analyze`
- Relevant `flutter test` tests.

Cover:

- Successful login.
- Invalid credentials.
- Validation without sending a request.
- Duplicate-tap prevention.
- Timeout and connection failure.
- Malformed login response.
- Secure-storage failure.
- Keep Me Signed In enabled and disabled.
- Valid and expired session restoration.
- Refresh coordination and failure, if supported.
- Protected-route redirects.
- Logout cleanup and late-response handling.

Manually verify:

- Login with a backend-provided test student account.
- API connectivity on an emulator or physical device.
- App restart behavior.
- Back navigation after login and logout.
- Existing Figma layout, keyboard behavior, and loading button.

Report only checks actually performed.

## 17. Change and Decision Log

Append an entry to `spec-md/00-changes-decision.md` containing:

- Implementation date.
- Next sequential decision ID.
- Scope: Student Login API Integration.
- Verified backend contract and environment.
- Removal of static authentication.
- Session persistence and refresh decisions.
- Files changed.
- Tests and manual checks performed.
- Known limitations or unresolved backend requirements.

Never include passwords, access tokens, refresh tokens, or private keys.

## 18. Acceptance Criteria

- [ ] Login uses the verified backend student API.
- [ ] Static credential checks and demo bypasses are removed.
- [ ] Existing Figma login design is preserved.
- [ ] Loading and errors behave correctly.
- [ ] Successful login opens Home.
- [ ] Protected routes require an authenticated session.
- [ ] Keep Me Signed In matches its documented behavior.
- [ ] Session restoration handles expiry and network failures.
- [ ] Refresh works if supported by the backend.
- [ ] Logout clears local session and user-specific data.
- [ ] No passwords or tokens appear in logs or plain storage.
- [ ] Relevant checks pass.
- [ ] `spec-md/00-changes-decision.md` is updated.