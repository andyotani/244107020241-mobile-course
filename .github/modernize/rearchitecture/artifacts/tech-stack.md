# Existing Tech Stack

## Language and Runtime

- Flutter `3.47.2` stable; Dart `3.13.2` stable (observed with `flutter --version` and `dart --version`).
- `pubspec.yaml` requires Dart `^3.13.2`.
- Flutter client with platform project folders for Android, iOS, web, Linux, macOS and Windows. Firebase options are generated for Android/iOS/macOS/Windows/web; Linux is explicitly unsupported by the current options getter.

## Dependencies

Declared constraints are from `pubspec.yaml`; resolved versions are from the checked-in `pubspec.lock`.

| Package | Constraint | Resolved | Observed use |
|---|---:|---:|---|
| `flutter` (SDK) | SDK | current Flutter SDK | UI/runtime |
| `cupertino_icons` | `^1.0.8` | `1.0.9` | Flutter icon assets |
| `flutter_riverpod` | `^3.4.3` | `3.4.3` | State and provider wiring |
| `go_router` | `^18.1.2` | `18.1.2` | App routes/auth redirects |
| `dio` | `^5.11.1` | `5.11.1` | No `lib/` usage found |
| `flutter_secure_storage` | `^11.2.0` | `11.2.0` | Access/refresh token storage |
| `firebase_core` | `^5.1.0` | `5.1.0` | Firebase initialization |
| `firebase_messaging` | `^17.0.1` | `17.0.1` | FCM permission/token/topic/message callbacks |
| `flutter_local_notifications` | `^22.3.3` | `22.3.3` | Local notifications and Android channel |
| `shared_preferences` | `^2.5.6` | `2.5.6` | Notification JSON persistence |
| `flutter_lints` (dev) | `^6.0.0` | `6.0.0` | Lint baseline |
| `flutter_test` (SDK dev) | SDK | current Flutter SDK | One widget test |

No Firebase Authentication or HTTP client usage is present in the inspected source. `AuthRepository` is a local demo implementation; `dio` is declared but has no `lib/` call site.

## Build/Analysis Configuration

- `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`; `build/` and platform directories are excluded from analysis.
- No version migration is in scope. Preserve the existing package constraints and installed toolchain.
