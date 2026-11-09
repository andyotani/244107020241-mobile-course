---
schema: clarification-answers/v1
status: submitted
generated_at: "2026-11-08T23:56:34.848Z"
scope: [frontend, generic]
questions_file: clarification-questions.json
---

# Rearchitecture Clarification Answers

## 🖥️ Frontend

- **F1** Should the refactor keep Flutter and the current repository's Flutter/Dart SDK versions, or target another framework/version?
  - answer: Flutter; preserve the versions currently declared by the repository
  - source: user
- **F2** Which Flutter widget/component library and visual conventions should the refactor preserve or target?
  - answer: _none_
  - source: skipped (required, no default — blocking gap)
- **F3** Provide screenshots, screen recordings, or a staging URL for the existing Login/authentication UI, or state that no visual UI reproduction is required for this architecture-only refactor.
  - answer: _none_
  - source: skipped (required, no default — blocking gap)
- **F4** What design system, theme, or design-token source should the implementation retain?
  - answer: match existing pixel-by-pixel
  - source: user
- **F5** What accessibility standard should the UI meet?
  - answer: WCAG 2.1 AA
  - source: user
- **F6** Which mobile platforms and runtime versions must the app support?
  - answer: modern evergreen (Chrome, Firefox, Safari, Edge — latest 2 major versions)
  - source: user
- **F7** What responsive/adaptive behavior should be preserved for supported device sizes and orientations?
  - answer: mobile-first using existing breakpoints detected from codebase
  - source: user
- **F8** Which locales are in scope for the refactor?
  - answer: preserve current locales; keep existing i18n library if present
  - source: user
- **F9** Confirm the state-management/dependency-injection preference for the refactor.
  - answer: Riverpod, preserving current repository conventions where possible
  - source: user
- **F10** Which navigation/routing approach should be used while preserving existing login and notification navigation behavior?
  - answer: use the de-facto router for the chosen target framework
  - source: user

## 📋 General

- **G1** Confirm the success criteria: preserve Login, Authentication, Firebase Messaging, and Notification behavior, complete the requested architecture refactor, and pass applicable formatting, analysis, tests/build, and available runtime validation.
  - answer: Preserve Login, Authentication, Firebase Messaging, and Notification behavior; complete the architecture refactor and pass applicable formatting, analysis, tests/build, and available runtime validation.
  - source: user
- **G2** Confirm excluded scope: do not disturb unrelated worktree changes. Are any additional files, features, or behaviors explicitly out of scope?
  - answer: Do not disturb unrelated worktree changes; infer other exclusions from project structure.
  - source: user
- **G3** What should happen to the existing test suite during the refactor?
  - answer: must pass
  - source: user
- **G5** Add any other requirements, exclusions, dependencies, compliance rules, or operational constraints not covered above.
  - answer: None beyond the decisions listed in this specification.
  - source: user
