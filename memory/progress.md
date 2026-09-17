# Progress

_Last updated: 2026-09-17_

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
- [x] Empty UI-test results via configurable `StubGamesRepository` (no ViewModel `searchText` seeding)
- [x] Fix MainActor isolation compile error: `@MainActor` on `StubGamesRepository.forUITests()`
- [x] Cleanup batch: backtick GWT test names, AccessibilityIdentifiers SPM, UI POM, C API key (not Info.plist), flatten Infrastructure, lazy AppContainer, inline UI-test stub, OptimizedAsyncImage keep + README note
- [x] Fold API key + `DEVELOPMENT_TEAM` into gitignored `Config.xcconfig`; track `Config.xcconfig.sample`; remove `Secrets.xcconfig`
- [x] Shared `httpClient` + interceptors as lazy vars on `AppContainer` (reuse for future repositories)

- [x] Commit cleanup batch on `develop` (flatten, a11y SPM, POM pages, Config.xcconfig sample, shared httpClient)
- [x] `AppContainer.Overrides` + thin UITest bootstrap (`UITestSupport.makeOverrides()`)
- [x] POM scaffolding: `AppLauncher`, fluent page nav, split UITest files, adaptations doc
- [x] Async throwing page-object accessors (`try await page.screen`); UI tests `async throws`
- [x] Game Details UI coverage: content chips/description/website + error/Retry via `UITEST_FORCE_DETAILS_FAILURE`
- [x] `AppContaining` + production `AppContainer` + DEBUG `DebugAppContainer` (wrap + Overrides)

### Open

- [ ] Continue hexagonal/SDD feature work on `develop`
