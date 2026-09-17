# Active Context

_Last updated: 2026-09-17_

## Branch

- `develop` (async throwing POM accessors)

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Page objects: `try await list.screen` / `gameRows` / `emptyState` / `details.screen` (throw on timeout)
- UI tests are `async throws`; absence via `requireNoGameRows`
- Documented in adaptations + decisions

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
2. New UI-test scenarios: launch env keys + stub fields via `UITestSupport.makeOverrides()`
