# Active Context

_Last updated: 2026-09-19_

## Branch

- `develop`

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Navigation shell refactor: `AppRootView` → `GamesNavigationView`; coordinator owns view construction (`Route.gamesList`, `.details`)
- Coordinator injected via `.environment` at `AppRootView`; `GamesNavigationView` preview uses `DebugAppContainer` + stub use case
- Per-screen UI folders: screen view + ViewModel at feature root; section/row views in `Subviews/`
- `UITestConfiguration` stub tables are native JSON dicts (no `SearchResponse` / `DetailsResponse` wrappers)

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
2. Add search/pagination entries in `gamesList.responses` when a UI test needs typed search or page 2
3. Optional: dedicated slow-details field if a loading-overlay UI assertion is needed
