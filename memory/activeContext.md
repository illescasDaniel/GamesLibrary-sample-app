# Active Context

_Last updated: 2026-09-19_

## Branch

- `develop`

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Async XCTWaiter waits in `XCUITestPOM` (`waitForExistenceAsync`), `get async throws` page accessors, parallel `async let` in multi-element tests. README UI-test section documents the ~14% suite speedup (70.3s → 60.4s). Pushed with sync-throwing cleanup commit (`3a4aa82`).

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
2. Add search/pagination entries in `gamesList.responses` when a UI test needs typed search or page 2
3. Optional: dedicated slow-details field if a loading-overlay UI assertion is needed
