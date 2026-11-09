# Feature-First Flutter Boundaries

Feature-first Flutter refactors should keep domain contracts framework-free and preserve isolate-specific composition for Firebase background handlers.

## What Happened

For `244107020241-mobile-course` task `t3`, the current app used Riverpod/GoRouter with technical folders and a top-level Firebase background handler. The target design groups authentication, home, notifications, and push integration by feature, while keeping use cases behind repository contracts. The background callback cannot rely on the foreground Riverpod container, so it needs an explicit data-layer composition path. Existing behavior includes local demo authentication and notification deletion when read; neither should be mistaken for implementation defects to “correct” during a structural refactor.

## Takeaway

For Flutter Feature-First Clean Architecture, place Riverpod wiring at a feature DI boundary, keep AsyncNotifier controllers in presentation, map persisted JSON models to domain entities, and keep Firebase/plugin APIs in data adapters. Preserve a top-level annotated FCM callback and give background isolates their own composition. Avoid creating models for values that have no distinct serialized data shape.

## History

- 2026-11-09 (`244107020241-mobile-course/t3`): initial
