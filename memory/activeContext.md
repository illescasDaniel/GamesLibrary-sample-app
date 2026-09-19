# Active Context

_Last updated: 2026-09-19_

## Branch

- `develop`

## Current focus

Move shared-process UI-test bootstrapping into `UITestAppContent` (`scenarioHost` + coordinator + container).

## Just changed

- Fixed DEBUG app unit-test detection: `UnitTestProcessInfo` checks `XCTestBundlePath` / `XCTestConfigurationFilePath` (Xcode test-host signals), not only `IS_TESTING`.
- Moved `uiTestSessionGeneration` into `UITestAppContent`; dropped legacy `DebugAppContainer.Overrides.uitestFromLaunchEnvironment()`.
- Added `UnitTestProcessInfoTests` (Swift Testing); `IS_TESTING=1` on `GamesLibraryTests` scheme.

## Next steps

1. Move `scenarioHost` (and shared-process coordinator/container wiring) into `UITestAppContent`; slim `DebugGamesLibraryApp`.
2. Continue hexagonal/SDD feature work (new screens: IDs → nested page accessors → feature UITest file)
3. Optional: publish `AsyncSharedTestingKit` to its own GitHub repo when ready
