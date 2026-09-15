# Progress

_Last updated: 2026-09-14_

## Hexagonal + SDD refactor (in progress on `develop`)

Working tree on `develop` — not yet committed.

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

### Open

- [x] Commit hexagonal + SDD + memory-bank work when Daniel asks
- [x] Re-indent project source with tabs (per `AGENTS.md`)
