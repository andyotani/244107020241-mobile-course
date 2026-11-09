## [f717143a-f653-4973-8438-046898d37371] Resumed clarification gate for Flutter refactor
- Existing state has `clarification-questions.json` with `awaiting_answers`; no submitted `clarification-answers.md` or completed `clarification.md` exists.
- The project profile classifies this as an in-place Flutter architecture refactor; the user specified Feature-First layers and Riverpod, and requested preserving the current stack and component conventions.
- Do not read answer fields from the question JSON. The exact Flutter major version, named UI/component library, and screenshots are not provided in the user message or project profile; these required fields have no defaults, so non-interactive mode requires BLOCKED.
- No source files were inspected or changed. Learnings consumed: none.

## [f717143a-f653-4973-8438-046898d37371] Recorded user-authorized clarification defaults
- The user directly authorized keeping the current Flutter/Dart toolchain and dependencies and proceeding without screenshots or a form; recorded each as a pragmatic default with verification notes for implementation.
- The clarification skill accepts these explicit user-supplied free-text resolutions; do not treat absent exact version strings or images as blockers when the user has authorized preservation defaults.
- No application source or README was inspected, per this task's boundary; downstream implementation must still inspect them as originally requested.
- A scoped `git status` showed the target Flutter project directory as untracked. Preserve its existing contents; no application files were changed by this task. 
- Learnings consumed: none. 

## [t2] Current Flutter architecture and behavior boundaries
- The package README is still boilerplate; use source as the behavior baseline.
- AuthRepository is a delayed local demo, not Firebase Auth or a remote API. Do not silently substitute a real identity system in architecture/implementation.
- `AppNotification` is declared alongside the SharedPreferences store; the nominal model and repository files are zero-byte placeholders.
- FCM background and foreground flows write notifications to the same SharedPreferences JSON key read by the inbox. Preserve both routes and dedupe/order semantics.
- The target package is untracked; do not clean/reset it. Analysis artifacts are isolated under `.github/modernize/rearchitecture/artifacts/`.
- Learnings consumed: [architect/authorized-clarification-defaults]

## [t3] Designed feature-first architecture
- Package README is starter boilerplate; actual source and t1 behavior inventory are the product contract.
- Selected feature folders for authentication, home, notifications, and push messaging, with `app/` as the bootstrap/router composition boundary.
- Keep Riverpod state in presentation, manual provider wiring in feature DI, domain contracts framework-free, and data models responsible for JSON mapping.
- Firebase background handlers must use an independent composition path because a foreground Riverpod container cannot be assumed in the background isolate.
- Preserve the local demo auth, existing notification JSON/key/dedupe/order, delete-on-read semantics, and distinct push/inbox routing.
- Learnings consumed: [architect/authorized-clarification-defaults]
