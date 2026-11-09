# Local Login and Notification Parity

The campus notification app's current sign-in and notification lifecycle contain important behaviors that are not obvious from the screen labels alone.

## What Happened

For `244107020241-mobile-course` task `t1`, source inspection found Login is simulated locally (email contains `@`, password length at least six, synthetic persisted token values), and tapping a notification deletes it rather than retaining a read item. Push route fallback depends on whether the user opened the notification or tapped an item in the notification list.

## Takeaway

When documenting or validating parity for this app, derive login and notification expectations from the repository implementation, not product labels. Explicitly test the route matrix and the remove-on-tap side effect; do not describe the current behavior as server/Firebase authentication or retained read history.

## History
- 2026-11-09 (244107020241-mobile-course/t1): initial
