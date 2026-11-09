# t2 — Current Flutter Architecture Analysis

## Summary

The target is a single-module Flutter app with a working but informal layer split: `pages/`, `providers/`, `data/`, `messaging/`, and `models/`. Login/session behavior, notification persistence, and Firebase Messaging behavior are source-anchored in the artifacts below. The target directory is currently untracked; no application files were changed.

The package README is still the generic Flutter starter README. Authentication is a local delayed demo implementation, not Firebase Authentication or a remote API. `notification_repository.dart` and `models/notification_model.dart` are zero-byte placeholders; the actual `AppNotification` model is declared in `data/notification_store.dart`.

## Deliverables

- [architecture_index.md](./architecture_index.md) — implementation guide and per-unit navigation.
- [project-structure.md](./project-structure.md) — app type, package breakdown, entry points, and current layer organization.
- [tech-stack.md](./tech-stack.md) — verified Flutter/Dart versions and declared dependency constraints.
- [data-model.md](./data-model.md) — current persisted notification/session data shapes.
- [unit_graph.yaml](./unit_graph.yaml) — application entry-point graph and unique source anchors.
- [migration_boundary.yaml](./migration_boundary.yaml) — runtime refactor scope; generated/platform assets remain outside source rewrite.
- [wire_contracts.yaml](./wire_contracts.yaml) — Firebase Messaging message/topic contracts; no HTTP API found.
- [shared_modules.yaml](./shared_modules.yaml) — cross-unit Riverpod, Firebase options, and notification-store references.
- [cross_unit_state.yaml](./cross_unit_state.yaml) — persisted notification flow from push delivery to inbox.
- [units/app-shell/](./units/app-shell/) — startup, route guard, Firebase bootstrap behavior/bindings/split candidates.
- [units/login-authentication/](./units/login-authentication/) — login and local token-session behavior/bindings/split candidates.
- [units/home-dashboard/](./units/home-dashboard/) — home page behavior/bindings/split candidates.
- [units/notification-inbox/](./units/notification-inbox/) — inbox, persistence, and item-action behavior/bindings/split candidates.
- [units/push-messaging/](./units/push-messaging/) — FCM and local-notification behavior/bindings/split candidates.

## Validation and Limits

- Inspection only; no source, dependency, platform, or test files were changed.
- Evidence is static source inspection plus the installed `flutter --version` / `dart --version` and `pubspec.yaml` / `pubspec.lock`.
- No build or test run was part of this analysis assignment.
- App README is boilerplate; use source behavior as the preservation baseline.
- One existing widget test expects uppercase `LOGIN`, while the button source is title-case `Login`; report this as a test/source discrepancy for validation, not as verified test failure.

## Upstream Artifacts Consumed

- `.github/modernize/rearchitecture/clarification.md` — applied the user's authorization to retain current Flutter/UI dependencies and visual behavior, with no clarification wait.
- `.github/modernize/rearchitecture/artifacts/project-profile.yaml` — used for the single-module Dart scope and no-grouping context.

## Evidence Mapping

- `clarification.md#Generic` and `#Downstream Usage Notes` → current UI/dependency/platform preservation constraints in `migration_boundary.yaml` and `tech-stack.md`.
- `project-profile.yaml#project.scope_path` and `#assessment.change_type` → the analyzed package path and in-place refactor scope.
- Target `README.md`, `pubspec.yaml`, `lib/`, and `test/` → current package/layer/behavior evidence in the linked architecture artifacts.
