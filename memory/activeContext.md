# Active Context

_Last updated: 2026-09-17_

## Branch

- `develop` (uncommitted: UI-test helpers + expanded Game Details UI coverage)

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Game Details a11y IDs + page accessors (description, website, chips, platforms, error)
- Stub enriched; `UITEST_FORCE_DETAILS_FAILURE` fail-once for error + Retry recovery
- Root id swap for details error (`ContentUnavailableView` inherits parent id)
- `GameDetailsUITests`: 5 scenarios, all green

## Next steps

1. Commit uncommitted DI + UI-test helper work if desired
2. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
3. Optional: dedicated slow-details env if a loading-overlay UI assertion is needed
