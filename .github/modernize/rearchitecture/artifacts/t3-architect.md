# t3 — Feature-First Clean Architecture Design

## Decision

Refactor the app into three user-facing features—`authentication`, `home`, and `notifications`—plus a small `push_messaging` integration feature and an `app` composition layer. Keep a single Flutter package, the existing Riverpod/GoRouter/Firebase dependencies, routes, screens, platform targets, and generated Firebase options. Do not introduce code generation or a new state-management/routing package.

The package README is Flutter starter boilerplate; use the current source behavior and t1 inventory as the product contract. Authentication remains a delayed local demo, not Firebase Auth or a network API.

## Target Structure

Paths are relative to `07-week-7-clean-architecture/campus_notif_clean_architecture/`.

```text
lib/
  main.dart                               # Flutter/Firebase bootstrap only
  app/
    campus_notif_app.dart                 # MaterialApp, one-time push setup
    app_router.dart                       # GoRouter routes and auth redirect
  features/
    authentication/
      domain/
        entities/auth_session.dart
        repositories/auth_repository.dart
        usecases/login.dart
        usecases/restore_session.dart
        usecases/logout.dart
      data/
        datasources/demo_auth_data_source.dart
        datasources/secure_token_data_source.dart
        repositories/auth_repository_impl.dart
      di/authentication_providers.dart
      presentation/
        providers/auth_state_provider.dart
        pages/login_page.dart
    home/
      presentation/pages/home_page.dart
    notifications/
      domain/
        entities/notification_entity.dart
        repositories/notification_repository.dart
        usecases/get_notifications.dart
        usecases/add_notification.dart
        usecases/mark_notification_as_read.dart
        usecases/delete_notification.dart
        usecases/clear_notifications.dart
      data/
        models/notification_model.dart
        datasources/notification_local_data_source.dart
        repositories/notification_repository_impl.dart
      di/
        notification_providers.dart
        background_notification_composition.dart
      presentation/
        providers/notification_state_provider.dart
        pages/notification_page.dart
    push_messaging/
      data/push_service.dart              # Firebase/local-notification adapter
```

`firebase_options.dart`, platform directories, assets, `pubspec.yaml`, lockfile, and lint configuration remain as-is. Leave unused legacy placeholder files in place unless the implementer intentionally replaces them and verifies all references. Do not keep new feature code in the old top-level `pages/`, `providers/`, `data/`, `models/`, or `messaging/` folders.

## Layer and Dependency Contracts

| Area | Owns | May depend on | Must not depend on |
|---|---|---|---|
| `domain` | Entities, abstract repository contracts, use cases | Dart and other domain types in the same feature | Flutter, Riverpod, Firebase, SharedPreferences, secure storage, UI, concrete data classes |
| `data` | Repository implementations, persistence/API adapters, JSON models, FCM/plugin adapter | Its feature domain contracts/entities and declared packages | Presentation widgets/controllers |
| `presentation` | Existing screens, Riverpod async state/controllers, UI validation/rendering | Its feature domain/use-case providers; app navigation | Concrete data sources/repository implementations or Firebase/plugin types |
| `di` | Manual Riverpod provider wiring: data sources → repository contract → use cases | Domain contracts and data implementations | Widgets or UI rendering |
| `app` | Startup, Firebase bootstrap, router, feature composition/callbacks | Feature public presentation/DI APIs and platform bootstrap | Feature implementation internals beyond required composition |

Dependency direction is `presentation → use case → domain repository contract ← data repository implementation → data source`. Models map to/from entities; entities never contain JSON methods or framework annotations. Cross-feature reads are allowed only at presentation composition points: Home consumes the notifications public state for its badge and the authentication controller for logout; feature domain/data modules do not import another feature's presentation or data internals. Push messaging may call the notification feature's domain add-notification use case, but the notifications feature must not depend on push messaging.

### Domain contracts and use-case responsibilities

- `AuthRepository` exposes only the cohesive authentication operations needed by the app: login, determine whether an access token is present, and logout. `AuthSession` is a domain value with `access` and `refresh`.
- `Login`, `RestoreSession`, and `Logout` use cases delegate to that contract. `AuthRepositoryImpl` coordinates the local demo authentication adapter and secure-token adapter. Keep the existing 500 ms delay, trimmed-email input from the page, `@` and six-character acceptance rule, synthetic token values, exact error text, token keys, and sequential writes/deletes. Do not claim server-side authentication or add token refresh semantics.
- `NotificationRepository` exposes the app's focused list/add/remove/clear operations using `NotificationEntity`, not JSON maps or plugin types. Each notification use case delegates through this contract; list order and duplicate-ID behavior are repository guarantees.
- `MarkNotificationAsRead` intentionally preserves the current behavior: the selected notification is removed, not retained with `isRead: true`. Keep the `isRead` field in the entity/model and its persistence representation.
- Keep date acquisition for new notification records in one layer (the use-case/repository boundary), and preserve the current observable `DateTime.now()` behavior. Avoid inventing a clock abstraction unless needed by tests.
- Use cases are small one-operation classes; do not make Riverpod controllers or pages call repositories directly.

### Models, persistence, and failure behavior

- `NotificationEntity` is the domain representation: `id`, `title`, `body`, `date`, nullable `route`, and `isRead` (default `false`).
- `NotificationModel` is the data representation and owns JSON conversion. Preserve JSON keys `id`, `title`, `body`, `date`, `route`, and `isRead`; date remains ISO-8601. Preserve parsing defaults: title `Campus Notif`, body `''`, invalid/missing date `DateTime.now()`, and read only when JSON value is exactly `true`.
- `NotificationLocalDataSource` is a narrow persistence port; its SharedPreferences implementation retains key `campus_notifications`, malformed non-list JSON returning an empty list, and rethrowing storage/decode errors. The repository maps models to entities and returns newest-first data.
- Adding a duplicate `id` is a no-op. New records have current time and `isRead: false`. Remove/clear persist the same notification list/key semantics as today.
- A separate `AuthSessionModel` is not required: there is no serialized session payload, and the secure store persists two strings independently under `access_token` and `refresh_token`. Avoid a redundant model/entity pair for those strings.
- Keep user-visible errors compatible: required input shows `Email dan password harus diisi`; invalid credentials show `Email atau kata sandi tidak valid`; notification load errors remain visible as `Terjadi kesalahan: <error>`. Async repository errors must remain errors, never be converted into success/empty state except for the existing malformed-list case.

## Riverpod and App Wiring

- Use the already-installed `flutter_riverpod` APIs manually (`Provider`, `AsyncNotifierProvider`); no code generator or dependency change.
- Feature `di/*_providers.dart` provides data-source instances, repository implementation behind its domain contract, and use-case instances. Override contracts/providers in tests rather than concrete plugin classes.
- `auth_state_provider.dart` keeps the shared asynchronous signed-in state: startup reads access-token presence; Login exposes loading/error/success; Logout clears both keys then emits signed-out. The router listens for auth changes and retains the current loading/no-redirect, signed-out-to-`/login`, and signed-in-away-from-`/login` rules.
- `notification_state_provider.dart` exposes the notification list via `AsyncNotifierProvider<List<NotificationEntity>>`. Its actions call use cases and refresh state after successful persistence; it owns no storage/JSON code.
- Keep `CampusNotifApp` and `GoRouter` as the composition points, retaining `/login`, `/`, `/notifications`, initial `/`, and existing UI widgets/text. Home's badge remains hidden at zero and derives unread count from the notification state.
- `main.dart` initializes Flutter/Firebase before app startup, registers the top-level background entry point before `runApp`, and preserves the initialization failure screen. Push initialization remains once-after-first-frame and failure is logged without replacing the app.

## Firebase Messaging Boundary

`features/push_messaging/data/push_service.dart` owns Firebase Messaging and local-notification APIs. Keep Firebase/plugin types outside domain and presentation contracts; expose message handling through callbacks/domain use cases.

- Preserve the top-level `@pragma('vm:entry-point')` background handler. It must remain directly registered by Firebase Messaging and independently initialize Firebase/plugin registration. Do not assume a Riverpod container exists in the background isolate.
- `background_notification_composition.dart` constructs the notification add use case and its data dependencies for that isolate. The handler persists only messages with a notification payload; its ID fallback remains message ID, then sent-time milliseconds, then current-time milliseconds.
- Foreground notification payloads are added through the add use case before local display. Keep the foreground ID fallback of message ID or message hash, and do not persist/display data-only messages through the current notification-bearing path.
- Request alert, badge, and sound permissions; continue token setup/topic subscription even when permission is denied. Retain auto-init, 30-second token timeout, refresh listener, and topic `pengumuman-kampus`. Do not persist the FCM token.
- Preserve `campus_notif_chime_v1`, `campus_notification`, channel importance/sound/vibration, and iOS alert/badge/sound configuration.
- Keep distinct route behavior: notification-open callbacks route only `/` to Home and every other/absent value to Notifications; tapping an inbox item removes it, stays for `/notifications`, navigates directly for `/` or `/login`, and otherwise falls back to Home.

## Practical SOLID Application

| Principle | Concrete boundary |
|---|---|
| SRP | Separate widget rendering, auth/notification state orchestration, each use case, repository mapping, JSON conversion, secure-token access, SharedPreferences access, and FCM/plugin lifecycle. |
| OCP | Add alternate auth or notification persistence by implementing the existing domain contract and wiring a provider override; do not modify use-case logic for each adapter. |
| LSP | Repository implementations must honor contract semantics: auth returns the same session or surfaces errors; notification reads are newest-first; duplicate adds are no-ops; remove/read and clear have the existing deletion semantics. |
| ISP | Keep feature-focused contracts with only operations the feature requires; keep local token and notification data-source ports narrow. Do not introduce a generic all-purpose storage/service interface. |
| DIP | Use cases import repository abstractions only. Riverpod DI is the composition root that supplies concrete adapters; UI and router depend on state/use-case providers, not persistence or Firebase classes. |

## Migration Map and Known Risks

| Existing runtime area | Target location | Risk / mitigation |
|---|---|---|
| `lib/main.dart` | `main.dart`, `app/` | **High:** startup order and route refresh are easy to regress. Preserve Firebase-before-`runApp`, handler registration, loading guard and fallback; keep route tests. |
| `lib/pages/login_page.dart`, `lib/data/auth_repository.dart`, `lib/data/token_store.dart`, `lib/providers/auth_provider.dart` | `features/authentication/` | **High:** demo auth can be mistaken for real auth; preserve local-only behavior, token keys, delay, validation and exact messages. |
| `lib/pages/notification_page.dart`, `lib/data/notification_store.dart`, `lib/providers/notification_provider.dart`, `lib/models/notification_model.dart` | `features/notifications/` | **High:** persisted JSON compatibility is externalized state. Preserve key/fields/defaults/order/dedupe and deletion-on-read. |
| `lib/messaging/push_service.dart` and app callbacks | `features/push_messaging/`, notification domain, `app/` | **High:** background handlers run outside Riverpod; keep a top-level entry point and independent data composition. |
| `lib/pages/home_page.dart` | `features/home/presentation/` | **Medium:** preserve the unread badge and both navigation/logout actions while switching imports to feature APIs. |

Known behavior to preserve despite awkwardness: background and foreground persistence share one key; current load-modify-save operations are not atomic across concurrent writers; inbox “read” deletes; push-open and inbox-item route fallbacks differ. Do not silently “fix” these as part of layering. The existing widget test asserts `LOGIN` while the source renders `Login`; retain the UI and align the assertion to source behavior when implementation updates the test.

## Implementation Completion Evidence

The implementation worker should report:

1. The files moved/created within `must_rewrite` and confirmation that Firebase options, dependency constraints, platform files, and unrelated worktree content were not changed.
2. The domain/data/presentation dependency direction and repository/use-case/provider wiring, with no plugin or persistence imports in domain.
3. Preservation checks for the t1 login/session, route, FCM, notification JSON, ordering, duplicate, delete/read, empty/error, and routing cases.
4. Formatting, analyzer, available tests, and full Flutter build results. FCM runtime/device coverage should be identified separately if no configured device exists.
5. Hot restart/reload evidence only if a running Flutter app is available; otherwise state that no live app was available. This design task itself changed no Dart code and did not perform a hot restart.

## Upstream Artifacts Consumed

- `.github/modernize/rearchitecture/artifacts/t1-pm.md` — behavior requirements, exact routes/messages, notification persistence, and behavior edge cases.
- `.github/modernize/rearchitecture/artifacts/t2-architect.md` — current package structure, dependency versions, data model, and links to source-anchored contracts.
- `.github/modernize/rearchitecture/artifacts/project-structure.md` — verified package scope, old technical-folder split, entry points, and platform boundary.
- `.github/modernize/rearchitecture/artifacts/tech-stack.md` — existing Flutter/Dart, Riverpod, GoRouter, Firebase, local-storage constraints; no dependency upgrades.
- `.github/modernize/rearchitecture/artifacts/data-model.md` — persisted notification schema, secure token keys, and local-demo session limitation.
- `.github/modernize/rearchitecture/artifacts/migration_boundary.yaml` — `must_rewrite` scope and preserved generated/platform files.
- `.github/modernize/rearchitecture/artifacts/unit_graph.yaml` — app/auth/home/inbox/push entry points, dependencies, and shared references.
- `.github/modernize/rearchitecture/artifacts/units/login-authentication/behavior.yaml` — login/session side effects, branches, error, and token-write behavior.
- `.github/modernize/rearchitecture/artifacts/units/notification-inbox/behavior.yaml` — notification persistence, dedupe, order, removal-on-read, and error semantics.
- `.github/modernize/rearchitecture/artifacts/units/push-messaging/behavior.yaml` and `bindings.yaml` — background entrypoint, foreground/open callbacks, permissions, token/topic, and channel binding.
- `.github/modernize/rearchitecture/artifacts/units/app-shell/behavior.yaml` — Firebase startup, redirects, callback routing, and startup fallback.
- `.github/modernize/rearchitecture/clarification.md` — authorization to preserve existing stack/UI/platform targets without another clarification round.

## Evidence Mapping

- `t1-pm.md#REQ-001–REQ-012`, `#Edge Cases` → migration map, entity/use-case behavior, routing and persistence contracts above.
- `units/login-authentication/behavior.yaml#side_effects,branches,error_paths` → auth use cases, local demo adapter, token data source, and AsyncValue error contract.
- `units/notification-inbox/behavior.yaml#side_effects,branches,error_paths` → NotificationEntity/Model, SharedPreferences adapter, use cases, ordering/dedupe, and deletion-on-read.
- `units/push-messaging/behavior.yaml#side_effects,branches,error_paths` and `bindings.yaml#bindings` → isolated background composition, push data adapter, retained listener/entrypoint/channel requirements.
- `units/app-shell/behavior.yaml#side_effects,branches,error_paths` → `main.dart`/`app/` separation, Firebase startup sequence, route guard, and fallback screen.
- `migration_boundary.yaml#must_rewrite,copy_as_is,legacy_allowed_to_remain` → in-scope feature moves and unchanged generated/platform/dependency files.
- `tech-stack.md#Dependencies` and `clarification.md#Frontend` → existing manual Riverpod and UI/dependency preservation; no new package or code generator.
