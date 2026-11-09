## [t1] Inventoried Login, authentication, messaging, and notification behavior
- Codebase/domain discoveries: The app's Login is a simulated local credential check, not Firebase Authentication; saved session presence is based on access token. Notification taps remove the item instead of retaining a read item, and route fallback differs between push-open and in-list taps.
- Wrong assumptions and corrections: The generic project README does not define behavior; the app source is the useful parity baseline. The root README contains only a title.
- Debugging dead-ends and what actually worked: `Get-Date -AsUTC` is unsupported in this PowerShell version; `(Get-Date).ToUniversalTime().ToString('o')` produced the required UTC timestamp.
- Techniques/patterns worth reusing for future tasks: Trace route guard, state provider, persistence, screen handlers, and push callbacks together to capture observable outcomes; distinguish source-derived behavior from device-only FCM proof. Existing widget test asserts `LOGIN`, but UI source renders `Login`.
- Learnings consumed: [(none)]
