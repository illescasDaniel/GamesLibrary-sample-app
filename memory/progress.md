# Progress

_Last updated: 2026-09-16_

## Hexagonal + SDD refactor (on `develop`)

### Done

- [x] Feature specs: [games-list](../specs/games-list/SPEC.md), [game-details](../specs/game-details/SPEC.md)
- [x] `GamesLibraryCore` local Swift package (entities, ports, use cases, Core tests)
- [x] Inbound adapters (SwiftUI views, `@Observable` ViewModels, formatters)
- [x] Outbound adapters (DTOs, mappers, repository, TTL cache, network)
- [x] Composition root: `AppContainer` + `AppCoordinator`
- [x] Unit tests migrated onto ports/DTOs; UI tests use `-UITesting` + `StubGamesRepository`
- [x] Agent playbooks, Cursor rules/skills, `AGENTS.md`
- [x] Agent memory bank (replicated from srxy): `memory/` + always-on `.cursor/rules/agent-memory.mdc`
- [x] Xcode 27 Apple agent skills exported into `.cursor/skills/` (SwiftUI, tests, App Intents, …)
- [x] Re-indent project source with tabs (per `AGENTS.md`)
- [x] Fix `GamesLibraryCore` `-Wincompatible-sysroot` (declare `.macOS("14.0")` alongside iOS for SourceKit / `swift test`)
- [x] Commit Package.swift platform fix + memory update
- [x] Confirm Package.swift editor warning cleared after platform declaration
- [x] Screen-owned ViewModels (`@State` in list/details views; container constructs at call site)
- [x] Games list initial load via `.task` (removed `onAppear` workaround)
- [x] Remove empty `GamesLibraryUITestsLaunchTests` (launch smoke covered by `GamesLibraryUITests`)
- [x] Agent worktree skills: `apply-worktree`, `delete-worktree` (adapted from srxy for iOS quality gate)

### Open

- [ ] Continue hexagonal/SDD feature work on `develop`
