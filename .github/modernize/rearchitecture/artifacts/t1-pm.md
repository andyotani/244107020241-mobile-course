# t1 — Login, Authentication, Messaging, and Notification Behavior Inventory

## Summary

This inventory records observable behavior in `07-week-7-clean-architecture/campus_notif_clean_architecture` as the parity baseline for the requested refactor. The app currently provides a simulated local login, authenticated navigation, Firebase Cloud Messaging setup, and a locally persisted notification center. The behavior scope below is based on source inspection; it does not imply a live authentication backend or a successful device-level push test.

## Scope Baseline

- **Discovery method**: Read the repository and project READMEs, then inspected the app entry point, all Login/Home/Notification screens, authentication and notification state/data files, push service, Android manifest, dependencies, and the widget test.
- **Total behavior areas discovered**: 8.
- **Items in scope**: 8/8 — startup and route access, login/logout, notification permission/setup, foreground/background delivery, notification-open routing, notification-list presentation, notification actions, and local persistence.
- **Project README context**: repository `README.md` contains only the repository title; the project README is the generic Flutter starter guide and documents no additional product behavior.
- **Preservation baseline**: existing labels, layout, routes, current local login rules, notification side effects, and platform-specific notification presentation are in scope. No redesign or new authentication/product capability is implied.

## User Scenarios & Testing

### User Story 1 — Sign in and reach the home screen (Priority: P1)

As a campus-app user, I can sign in with the app's accepted credentials and reach the home screen so that I can view campus announcements.

**Why this priority**: Authentication is the access gate for the home and notification screens.

**Independent Test**: Launch with no saved session, submit empty, invalid, and accepted inputs, then verify the visible feedback and resulting route.

**Acceptance Scenarios**:

1. **Given** there is no saved access token, **When** the app opens at its default route, **Then** the Login screen is shown.
2. **Given** either the trimmed email or the password is empty, **When** the user submits Login, **Then** the app shows “Email dan password harus diisi” and does not sign in.
3. **Given** a non-empty email that does not contain `@`, or a password shorter than six characters, **When** the user submits Login, **Then** the app shows “Email atau kata sandi tidak valid” and remains signed out.
4. **Given** an email containing `@` and a password of at least six characters, **When** the simulated login completes, **Then** access and refresh values are saved, the user is considered signed in, and the Home screen is shown.
5. **Given** Login is in progress, **When** the user views the Login button, **Then** the button is disabled and displays a progress indicator.
6. **Given** the password field is focused, **When** the user submits from the keyboard, **Then** the same Login action is performed.

### User Story 2 — Restore or end an existing session (Priority: P1)

As a returning user, I stay signed in while the saved access token exists, and I can log out to return to Login.

**Why this priority**: Session restoration and logout determine whether protected screens remain accessible.

**Independent Test**: Start with a saved access token, navigate to protected routes, log out, and attempt to reopen a protected route.

**Acceptance Scenarios**:

1. **Given** a non-null saved access token, **When** authentication state initializes, **Then** the user is treated as signed in and the Home route is available.
2. **Given** the user is signed in, **When** they select Logout, **Then** access and refresh values are cleared and Login is shown.
3. **Given** the user is signed out, **When** they open `/` or `/notifications`, **Then** navigation redirects to `/login`.
4. **Given** the user is signed in, **When** they open `/login`, **Then** navigation redirects to `/`.

### User Story 3 — Receive campus announcements (Priority: P1)

As a user with push capability, I can receive campus announcements while using the app or while it is in the background, and see them in the notification center.

**Why this priority**: Receiving and retaining announcements is the product's central purpose.

**Independent Test**: With a configured Firebase runtime/device, exercise a notification-bearing FCM message in foreground and background, then inspect the notification center and system presentation.

**Acceptance Scenarios**:

1. **Given** Firebase initializes successfully and the app starts, **When** push setup runs, **Then** the app requests alert, badge, and sound permission, enables FCM auto-init, attempts to obtain a token, and subscribes to `pengumuman-kampus`.
2. **Given** a foreground FCM message has a notification payload, **When** it arrives, **Then** it is stored once in the notification center and a local notification is displayed.
3. **Given** a background FCM message has a notification payload, **When** its background handler runs, **Then** it is stored once in the notification center.
4. **Given** a message has no notification payload, **When** the foreground or background handler receives it, **Then** it is not added by the current notification-bearing-message path.
5. **Given** notification permission is denied or unavailable, **When** push setup continues, **Then** token acquisition and topic subscription are still attempted; push setup does not present a dedicated permission-denied screen.
6. **Given** Firebase app initialization fails, **When** startup handles the failure, **Then** a fallback screen displays “Firebase gagal diinisialisasi:” and the initialization error.

### User Story 4 — Open an announcement from a push notification (Priority: P1)

As a user, I can tap a push notification and arrive at the relevant available app screen.

**Why this priority**: Notification interactions should lead to usable in-app content rather than an unavailable destination.

**Independent Test**: Tap a local notification, an FCM notification received while backgrounded, and a notification that launched a terminated app; vary the optional `route` payload.

**Acceptance Scenarios**:

1. **Given** a notification is opened while the app is backgrounded or terminated, **When** its `route` payload is `/`, **Then** the Home screen is opened.
2. **Given** a notification is opened while backgrounded or terminated, **When** its `route` is absent or any value other than `/`, **Then** the Notification screen is opened.
3. **Given** a local notification is tapped, **When** its payload is `/`, **Then** Home is opened; **when** its payload is any other value or absent, **Then** Notifications is opened.

### User Story 5 — Review and manage saved notifications (Priority: P1)

As a signed-in user, I can see recent announcements, their unread presentation, and an empty or error state where applicable.

**Why this priority**: The notification center is the durable in-app destination for announcements.

**Independent Test**: Seed no notifications and multiple notifications with different dates/read states; open the notification screen and exercise each list action.

**Acceptance Scenarios**:

1. **Given** notifications are loading, **When** the list is displayed, **Then** a progress indicator is shown.
2. **Given** no notifications are saved, **When** the list loads, **Then** the empty-state copy “Belum ada notifikasi” and “Pengumuman kampus akan muncul di sini.” is shown.
3. **Given** notifications are saved, **When** the list loads, **Then** the newest appears first and each item shows title, body, date/time, and a read/unread visual treatment.
4. **Given** notification loading fails, **When** the list is displayed, **Then** it shows “Terjadi kesalahan:” with the error.
5. **Given** one or more notifications are unread, **When** Home is displayed, **Then** the notification badge shows the unread count; **given** there are none, **Then** the badge label is hidden.
6. **Given** the user deletes one notification or clears all notifications, **When** the operation completes, **Then** the selected item or all items are removed without a confirmation step.
7. **Given** the user taps a notification item, **When** the action completes, **Then** that item is removed from the list/storage immediately and its payload route is handled: `/notifications` keeps the user on that page, `/` or `/login` is navigated to directly, and any other/absent value falls back to Home.

### User Story 6 — Retain session and notification state across launches (Priority: P2)

As a returning user, saved session and notification information remain available after the app is restarted.

**Why this priority**: Users should not lose their existing local access state or saved announcements between sessions.

**Independent Test**: Save a session and notifications, stop and relaunch the app, then verify the route, list order, contents, and unread badge.

**Acceptance Scenarios**:

1. **Given** the app is restarted with a saved access token, **When** initial authentication state loads, **Then** the user remains signed in.
2. **Given** one or more notifications were saved, **When** the app is restarted, **Then** they load with their original identifier, title, body, date, optional route, and read flag.
3. **Given** a duplicate notification identifier is received, **When** it is added, **Then** the existing item is retained and a duplicate is not added.

### Edge Cases

- A whitespace-only email is trimmed to empty and follows the required-fields validation; the password is not trimmed, so whitespace counts toward the six-character length.
- A non-empty malformed email is not checked for full email syntax; current acceptance checks only for `@`.
- Duplicate FCM message IDs are deduplicated by the notification store.
- A malformed persisted notification list is treated as empty; other storage/load exceptions can surface in the list error state.
- Optional route values outside the supported routes fall back to Home from an in-list tap; from a notification-open callback they lead to Notifications.
- The permission result does not gate token acquisition or topic subscription.
- Push initialization exceptions are logged; the app has no separate user-facing push-setup error page.

## Functional Requirements

- **REQ-001**: The app MUST show Login when there is no saved access token and restrict Home and Notifications to signed-in users.
- **REQ-002**: The Login screen MUST expose email and password fields, allow password visibility toggling, submit from the password keyboard action, and disable Login while a login attempt is in progress.
- **REQ-003**: The app MUST trim the email, reject empty email/password with the existing required-fields message, and accept login only when the email contains `@` and the untrimmed password has at least six characters; failure MUST be shown to the user.
- **REQ-004**: A successful login MUST persist access and refresh values, while Logout MUST clear both and return the user to Login.
- **REQ-005**: On startup, the app MUST initialize Firebase and, if that fails, show the existing initialization error fallback.
- **REQ-006**: The app MUST request alert, badge, and sound notification permission, attempt FCM token setup and refresh listening, and subscribe to the `pengumuman-kampus` topic during push initialization; permission denial MUST NOT prevent the latter attempts.
- **REQ-007**: A notification-bearing foreground FCM message MUST be stored without duplication and shown as a local notification; a notification-bearing background message MUST be stored.
- **REQ-008**: The notification-open flow MUST route `/` to Home and route any other/absent payload to Notifications.
- **REQ-009**: The notification center MUST show loading, error, empty, and populated states; populated items MUST be newest-first and show title, body, date/time, and read/unread styling.
- **REQ-010**: Home MUST show the count of unread notifications only when the count is greater than zero.
- **REQ-011**: Deleting one or all notifications MUST remove the corresponding persisted items; tapping an item MUST remove it immediately and apply the existing in-list route rules.
- **REQ-012**: Saved session and notification contents MUST survive app restart; adding a notification with an existing identifier MUST NOT create a duplicate.

## Key Entities

- **User session**: The app's persisted signed-in state and associated access/refresh values.
- **Campus notification**: An announcement with an identifier, title, body, date/time, optional destination route, and read status.
- **Push message**: An incoming campus announcement that may carry notification display content and an optional route.

## Success Criteria

### Measurable Outcomes

- **SC-001**: 100% of the Login, session restoration, protected-route, and Logout scenarios above produce the expected screen and visible feedback.
- **SC-002**: In configured-device tests, 100% of notification-bearing foreground and background test messages appear in the in-app list exactly once.
- **SC-003**: 100% of notification tap cases in the route matrix arrive at the expected available page, with the tapped item removed as described.
- **SC-004**: After a restart, 100% of saved notification fields and ordering are preserved, except notifications explicitly removed by a user action.
- **SC-005**: The notification screen presents the defined loading, empty, populated, and error states when each corresponding condition is supplied.

## Observed Boundaries and Baseline Discrepancies

- Login is currently a local simulated credential check with a 500 ms delay and synthetic token values. No Firebase Authentication, server credential validation, account creation, or password-reset flow is present in the inspected project.
- Although a read flag is present in stored notification data, tapping a notification removes it rather than retaining it as read.
- `test/widget_test.dart` expects exact text `LOGIN`, while the Login button source renders `Login`. This is a source-level test/baseline mismatch; it was not executed as part of this inventory.
- FCM delivery, OS permission prompts, and platform sound/vibration require a configured device/runtime and are not proven by source inspection.

## Upstream Artifacts Consumed

- `.github/modernize/rearchitecture/clarification.md` — used the resolved defaults for preserving the current Flutter project, routes, UI, and runtime targets, and the defined feature-parity goal.

## Evidence Mapping

- `clarification.md#Frontend` and `#Generic` → preservation boundaries and parity expectations in this inventory.
- `lib/main.dart` → REQ-001, REQ-005, REQ-008; User Stories 1–3.
- `lib/pages/login_page.dart` and `lib/pages/home_page.dart` → REQ-002–004, REQ-010; User Stories 1–2 and 5.
- `lib/providers/auth_provider.dart`, `lib/data/auth_repository.dart`, and `lib/data/token_store.dart` → REQ-001, REQ-003–004; simulated login and session scenarios.
- `lib/messaging/push_service.dart` and `android/app/src/main/AndroidManifest.xml` → REQ-005–008; User Stories 3–4.
- `lib/pages/notification_page.dart`, `lib/providers/notification_provider.dart`, `lib/data/notification_store.dart`, and `lib/models/notification_model.dart` → REQ-007–012; User Stories 3–6 and edge cases.
- `test/widget_test.dart` → Observed baseline discrepancy for exact Login button text.

## Verification

- Method: source and documentation inspection; no application files were changed.
- Runtime/device tests: not run for this documentation-only inventory. The project includes one widget test; the exact text mismatch above is recorded for the validation phase.
- Hot reload/restart: not applicable because this task changes no Dart/Flutter source and no application was started.

## Requirements Quality Checklist

### Requirement ID Coverage

- [x] All functional requirements use `REQ-XXX` IDs.
- [x] IDs are unique and sequential.

### Testability

- [x] Requirements describe observable outcomes suitable for independent verification.
- [x] User scenarios include concrete Given/When/Then acceptance conditions.

### Completeness

- [x] All 8 discovered behavior areas are in scope.
- [x] User scenarios are prioritized.
- [x] Requirements cover login, session access, push delivery, notification routing, and notification management.
- [x] Success criteria are measurable and user-outcome focused.

### Preservation Constraints

- [x] Clarification defaults for existing Flutter/toolchain, UI, routes, and runtime targets are reflected.
- [ ] Constitution alignment: no project constitution file was found in the rearchitecture context.
