# Active Context

_Last updated: 2026-09-19_

## Branch

- `develop`

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Extracted **`AsyncSharedTestingKit`** (`ASTK`, `ASTKApp`, `ASTKXCTest`) from `XCUITestPOM` + shared-process glue; deleted `XCUITestPOM/`.
- `GamesLibraryUITestKit` now depends on `ASTK`; dropped `UITestRuntime` / `UITestApplyHandler` / `UITestNavigationResetting`.
- `AccessibilityIdentifiers`: `GamesLibraryUITestTransport.deepLinkScheme` only; dropped URL transport + `UITest.ready`.
- `AppLauncher` → thin `SharedProcessLauncher` wrapper; page objects use `PageObject` / `NestedPageObject`.
- `UITestAppContent` inlines session shell (`.id` + ready marker + `UITestSessionCoordinator`) — avoids generic `UITestSessionView` demangle crash in this app hierarchy.
- ASTK: 11 Swift Testing unit tests; UI suite: 8/8 pass (~62s).

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → nested page accessors → feature UITest file)
2. Add search/pagination entries in `gamesList.responses` when a UI test needs typed search or page 2
3. Optional: publish `AsyncSharedTestingKit` to its own GitHub repo when ready
