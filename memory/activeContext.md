# Active Context

_Last updated: 2026-09-19_

## Branch

- `develop`

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Games list rows: `NavigationLink(value: Route.details(game))` replaces `Button` + `coordinator.push`; disclosure chevron via system list styling; `GameListView` no longer reads coordinator for row taps

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
2. Add search/pagination entries in `gamesList.responses` when a UI test needs typed search or page 2
3. Optional: dedicated slow-details field if a loading-overlay UI assertion is needed
