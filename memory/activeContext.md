# Active Context

_Last updated: 2026-09-17_

## Branch

- `develop` (POM + `AppContainer.Overrides` landed)

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- `AppContainer.Overrides` single-init seam; `UITestSupport.makeOverrides()` for DEBUG UI tests
- POM: `AppLauncher`, fluent `tapFirstGameRow() -> GameDetailsPage`, split `GamesListUITests` / `GameDetailsUITests`
- Documented in `docs/playbooks/GamesLibrary-adaptations.md`

## Next steps

1. Continue hexagonal/SDD feature work (new screens: add IDs → page → feature UITest file)
2. New UI-test scenarios: add launch env keys + stub fields via `UITestSupport.makeOverrides()`
