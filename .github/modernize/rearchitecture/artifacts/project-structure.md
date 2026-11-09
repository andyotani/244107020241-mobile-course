# Project Structure

## Classification

- Project type: single-module Flutter application (frontend/client); not a monorepo or library.
- Scope: `07-week-7-clean-architecture/campus_notif_clean_architecture`.
- Languages: Dart application code plus generated platform projects.
- Current source inventory: 13 Dart files under `lib/`, one Dart widget test under `test/` (14 total); profile reports 1,358 non-blank Dart LOC.

## Package Breakdown

| Path | Dart files | Current responsibility |
|---|---:|---|
| `lib/` | 2 | Flutter/Firebase bootstrap, app root/router, generated Firebase platform options |
| `lib/pages/` | 3 | Login, home, notification-list screens and user actions |
| `lib/providers/` | 2 | Riverpod auth and notification async state/notifiers |
| `lib/data/` | 4 | Demo auth/session, secure token storage, SharedPreferences notification storage; one empty repository placeholder |
| `lib/messaging/` | 1 | FCM lifecycle, permission, local notification channel/rendering and callbacks |
| `lib/models/` | 1 | Empty notification model placeholder |
| `test/` | 1 | Login-page widget smoke test |

This is not yet feature-first Clean Architecture: source is grouped by technical folders; presentation pages and Riverpod state are separate, but the repository/store/model concerns are mixed. `AppNotification` currently lives in `lib/data/notification_store.dart`; `lib/models/notification_model.dart` and `lib/data/notification_repository.dart` are 0-byte files.

## Entry Points and Routing

- `lib/main.dart:94` — async Flutter entrypoint; initializes Firebase before `runApp`.
- `lib/main.dart:24` — Riverpod-provided GoRouter and auth-state redirect logic.
- Routes: `/login` (`main.dart:53`), `/` (`main.dart:61`), `/notifications` (`main.dart:69`).
- `lib/main.dart:106` registers `firebaseMessagingBackgroundHandler`.
- `lib/messaging/push_service.dart:46` — top-level `@pragma('vm:entry-point')` background handler.
- `lib/main.dart:168` initializes push callbacks after the first frame.
- `test/widget_test.dart` is the only inspected app test.

## Configuration and Platform Boundaries

- `pubspec.yaml` — Dart SDK constraint, Flutter dependencies, package identity.
- `pubspec.lock` — resolved package versions.
- `analysis_options.yaml` — `flutter_lints` baseline and generated/platform exclusions.
- `lib/firebase_options.dart` — generated Firebase options, referenced by foreground app startup and the background handler.
- Platform directories exist for Android, iOS, web, Linux, macOS, and Windows. `DefaultFirebaseOptions.currentPlatform` has no Linux configuration and throws `UnsupportedError` on Linux.
- App README is the generic “A new Flutter project” starter text; it documents no project-specific architecture or behavior.

## Functional Areas

- Login/session: route gating, demo email/password validation, secure-storage token persistence, logout.
- Home: welcome view, notification badge/navigation, logout.
- Notification inbox: persisted list, unread count, read/delete/clear behavior.
- Push integration: Firebase Messaging initialization, permission/token/topic setup, background/foreground events, local notification display and click navigation.
