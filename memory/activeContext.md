# Active Context

_Last updated: 2026-09-18_

## Branch

- `develop` (local convenience packages)

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Extracted reusable helpers into three local Swift packages:
  - `IOSConveniences` — `ViewLoadState`, `HTMLText` (Foundation HTML scanner, no UIKit), `HTTPConveniences` (HTTIES interceptors + `URLQueryEncodable`)
  - `SwiftUIComponents` — `LoadingView`, `capsuleChipStyle()`, `onNearBottom`
  - `XCUITestPOM` — wait/require helpers + `LaunchEnvironmentCodec`
- GamesLibrary / unit tests / UI tests link the products; inlined originals deleted
- Package + app unit tests + UI tests green
- Added `/save-changes` skill (memory → commit → push)

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
2. Add `SearchResponse` rows in `UITEST_CONFIG` when a UI test needs typed search or page 2
3. Optional: dedicated slow-details field if a loading-overlay UI assertion is needed
4. Optional later: publish the local packages to GitHub (same grain as HTTIES / TTLCache)
