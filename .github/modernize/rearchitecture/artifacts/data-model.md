# Existing Data Model

## Persisted Local State

### Notification

- Current type: `AppNotification`, declared in `lib/data/notification_store.dart:11`; the nominal `lib/models/notification_model.dart` file is empty.
- Fields: `id: String`, `title: String`, `body: String`, `date: DateTime`, nullable `route: String?`, `isRead: bool` defaulting to `false`.
- JSON names: `id`, `title`, `body`, `date` (ISO-8601), `route`, `isRead`.
- Deserialization defaults: missing title → `Campus Notif`; missing body → empty string; missing/unparseable date → `DateTime.now()`; `isRead` true only for JSON boolean `true`.
- Storage: one JSON list in SharedPreferences under key `campus_notifications`; sorted newest-first after loading.
- Operations: load/save/add/remove/clear; duplicate IDs are not inserted. The store's `markAsRead` removes the record rather than persisting `isRead: true`.
- No relational database, ORM, or entity relationships are present.

### Authentication Session

- `AuthSession` in `lib/data/auth_repository.dart:2` is an in-memory result with `access` and `refresh` strings.
- `TokenStore` persists them through `flutter_secure_storage` under `access_token` and `refresh_token`.
- Authentication is not backed by a remote API or Firebase Auth. The access token's presence initializes auth state as logged in; `readRefresh` is defined but not used in the inspected app flow.

## Entity/Relationship Summary

- No database entities or relationships exist.
- `AppNotification` is the only persisted application record.
- `AuthSession` is a transient result whose two token values are persisted independently.
