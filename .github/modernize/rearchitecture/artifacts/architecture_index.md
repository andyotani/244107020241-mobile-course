# Architecture Index — Campus Notif

## Implementation Guide

This index is not the full contract. Do not implement from this file alone; follow the artifact paths below.

### Global artifacts

- `unit_graph.yaml` — all implementation workers: find their assigned unit; use its source anchors, dependencies, signatures, dynamic entrypoints, and shared references.
- `migration_boundary.yaml` — all implementation workers: implementation scope is `must_rewrite`; generated Firebase options and platform project files are preserved as-is. Source anchors are not automatically rewrite targets.
- `wire_contracts.yaml` — workers touching Firebase integrations: keep the inbound `RemoteMessage` fields and topic contract; there is no app-owned REST endpoint in the current code.
- `shared_modules.yaml` — workers using cross-unit state/integration: filter `modules` by `used_by_units`; preserve the listed public fields and do not duplicate shared stores/providers.
- `cross_unit_state.yaml` — workers changing push or inbox persistence: filter flows where `writer.unit` or `reader.unit` matches the assigned unit; maintain the persisted notification key/shape and confirm the foreground/background path in tests.
- `project-structure.md`, `tech-stack.md`, `data-model.md` — all workers: use these for current package boundaries, pinned stack/dependency constraints, and persisted data shape.
- `seams.yaml` — not emitted: analysis found no deliberate partial-migration cut between separately maintained application units. Firebase/SharedPreferences are external integration contracts, not frozen internal code seams.

### Unit: `app-shell`

- External trigger: application launch; route guard and root router.
- Must read:
  - `units/app-shell/behavior.yaml` — startup, auth redirects, Firebase startup fallback, callback behavior.
  - `units/app-shell/bindings.yaml` — ProviderScope, GoRouter, Firebase initialization and background handler registration.
  - `units/app-shell/unit_decomposition.yaml` — advisory only; `commit: false`.
- Relevant global rows: `wire_contracts.yaml` where `unit: push-messaging`; `shared_modules.yaml` where `used_by_units` includes `app-shell`; `cross_unit_state.yaml` where the writer or reader is `app-shell` (none currently).
- Before DONE report: paths read, preserved startup/redirect behavior, unresolved startup/platform issues, and build/runtime evidence.

### Unit: `login-authentication`

- External trigger: `/login` page and session restoration/logout actions.
- Must read:
  - `units/login-authentication/behavior.yaml` — input validation, demo login result/error, token storage, restoration, logout.
  - `units/login-authentication/bindings.yaml` — Riverpod auth-state provider and route consumer.
  - `units/login-authentication/unit_decomposition.yaml` — advisory only; `commit: false`.
- Relevant global rows: `shared_modules.yaml` where `used_by_units` includes `login-authentication`; no current wire contract or cross-unit implicit state flow.
- Before DONE report: preserved validation/messages/loading/result, secure token keys and clear/read behavior, unresolved auth-service assumptions, and tests.

### Unit: `home-dashboard`

- External trigger: `/` page.
- Must read:
  - `units/home-dashboard/behavior.yaml` — unread badge, inbox navigation, logout and landing behavior.
  - `units/home-dashboard/bindings.yaml` — GoRouter/Riverpod bindings.
  - `units/home-dashboard/unit_decomposition.yaml` — advisory only; `commit: false`.
- Relevant global rows: `shared_modules.yaml` where `used_by_units` includes `home-dashboard`; no direct wire contract or cross-unit implicit state flow.
- Before DONE report: preserved navigation, unread count and logout effects, plus verification evidence.

### Unit: `notification-inbox`

- External trigger: `/notifications` page; list, read, delete, clear, and refresh actions.
- Must read:
  - `units/notification-inbox/behavior.yaml` — local storage format/order, de-duplication, error paths, removal-on-read and route rules.
  - `units/notification-inbox/bindings.yaml` — route and Riverpod notifier bindings.
  - `units/notification-inbox/unit_decomposition.yaml` — advisory only; `commit: false`.
- Relevant global rows: `shared_modules.yaml` where `used_by_units` includes `notification-inbox`; `cross_unit_state.yaml` where reader/writer is `notification-inbox`; `wire_contracts.yaml` where unit is `notification-inbox` (none).
- Before DONE report: preserved stored fields/key/order/dedupe/removal behavior, cross-unit push flow evidence, unresolved malformed-storage behavior, and tests.

### Unit: `push-messaging`

- External trigger: Firebase Messaging foreground/background/opened/terminated events.
- Must read:
  - `units/push-messaging/behavior.yaml` — permission/token/topic setup, message persistence/rendering, background handling and click routing.
  - `units/push-messaging/bindings.yaml` — Firebase handler registration, plugin callback/listener wiring, channel details.
  - `units/push-messaging/unit_decomposition.yaml` — advisory only; `commit: false`.
- Relevant global rows: `wire_contracts.yaml` where `unit: push-messaging`; `shared_modules.yaml` where `used_by_units` includes `push-messaging`; `cross_unit_state.yaml` where writer/reader is `push-messaging`.
- Before DONE report: preserved notification-vs-data-only handling, local display, storage and route fallback, topic/token lifecycle, and runtime verification on available targets.

## Upstream Artifacts Consumed

- `.github/modernize/rearchitecture/clarification.md` — preservation constraints and authorization to proceed.
- `.github/modernize/rearchitecture/artifacts/project-profile.yaml` — single-project scope.

## Evidence Mapping

- `clarification.md#Generic` → unit behavior and migration scope are constrained to preserving current UI/runtime behavior.
- `project-profile.yaml#project.scope_path` → package path used by every source anchor.
