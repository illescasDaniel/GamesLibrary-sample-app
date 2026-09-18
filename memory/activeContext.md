# Active Context

_Last updated: 2026-09-18_

## Branch

- `develop`

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Shared-process UI tests: one launch (`UITESTING=1`), runtime apply via deep-link URL + `XCUIDevice.shared.system.open`, ready marker
- Extracted `GamesLibraryUITestKit`; app glue in `GamesLibrary/App/UITest/`; production `RootView` / `AppCoordinator` clean
- Documented reload + config-passing flow in `GamesLibrary-adaptations.md`
- API key moved to gitignored `Secrets.swift` (+ sample); removed C/bridging header
- Removed deprecated `UITestAppDelegate` (SwiftUI `.onOpenURL` only)

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
2. Add `SearchResponse` rows in `UITEST_CONFIG` when a UI test needs typed search or page 2
3. Optional: dedicated slow-details field if a loading-overlay UI assertion is needed
