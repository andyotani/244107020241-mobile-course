# User-Authorized Clarification Defaults

Explicit user authorization to proceed with a preservation default can resolve a required clarification without pretending unavailable specifics were verified.

## What Happened

In the Flutter architecture-refactor clarification for task `f717143a-f653-4973-8438-046898d37371`, the user directed the workflow to retain the current toolchain and UI dependencies and proceed without new screenshots or another form submission. The canonical clarification recorded these as user-authorized defaults, noted verification limits, and did not mark them as blocking gaps. A scoped status check also showed the target project directory is untracked, so it must be preserved as existing worktree content.

## Takeaway

When a user explicitly authorizes a pragmatic default for a required field, record both the chosen preservation rule and the unresolved evidence limitation. Do not claim exact versions, dependencies, or visual details were inspected; require the implementation role to verify them when source inspection is in scope. If the target project is reported as untracked, warn downstream workers to avoid destructive cleanup/reset operations.

## History

- 2026-11-08 (`244107020241-mobile-course/f717143a-f653-4973-8438-046898d37371`): initial
