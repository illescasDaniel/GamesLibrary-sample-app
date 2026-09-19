# Active Context

_Last updated: 2026-09-19_

## Branch

- `develop`

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Moved shared-process UI-test bootstrapping into `UITestAppContent` (parameterless init: host + `DebugAppContainer` overrides + coordinator + session shell).
- Slimmed `DebugAppContainer` to `Overrides` only; dropped stored `scenarioHost` and UITestKit import.
- Extracted private `DebugAppContent` / Release `AppContent` shells — `@main` structs route only; coordinator `@State` lives in content views.
- Fixed `@State` for `coordinator`/`scenarioHost` in `UITestAppContent` so apply handshake stays stable across SwiftUI re-inits.
- All tests green: 45/45 (37 unit + 8 UI).

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → nested page accessors → feature UITest file)
2. Add search/pagination entries in `gamesList.responses` when a UI test needs typed search or page 2
3. Optional: publish `AsyncSharedTestingKit` to its own GitHub repo when ready
