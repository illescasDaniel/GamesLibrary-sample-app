# Active Context

_Last updated: 2026-09-16_

## Branch

- `cursor/stub-games-repository-uitest-4f36`

## Current focus

Remove UI-test ViewModel seeding from `AppContainer`; drive empty-results via configurable `StubGamesRepository`.

## Just changed

- `StubGamesRepository` → mutable class with `games` / `forUITests()` factory
- `DebugGamesLibraryApp` wires `StubGamesRepository.forUITests()`
- Removed `#if DEBUG` `searchText` seeding from `makeGamesListViewModel()`
- Dropped `noResultsSearchQuery` / magic query matching
- Playbook + memory updated

## Next steps

1. Commit / push / open PR to `develop`
2. Run unit + UI tests if simulator available
