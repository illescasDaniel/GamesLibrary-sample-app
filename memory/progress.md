# Progress

_Last updated: 2026-09-19_

## Hexagonal + SDD refactor (on `develop`)

### Done

- [x] Feature specs: [games-list](../specs/games-list/SPEC.md), [game-details](../specs/game-details/SPEC.md)
- [x] `GamesLibraryCore` local Swift package (entities, ports, use cases, Core tests)
- [x] Inbound adapters (SwiftUI views, `@Observable` ViewModels, formatters)
- [x] Outbound adapters (DTOs, mappers, repository, TTL cache, network)
- [x] Composition root: `AppContainer` + `AppCoordinator`
- [x] Unit tests migrated onto ports/DTOs; UI tests use `UITEST_CONFIG` + stub use cases
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
- [x] Empty UI-test results via configurable stub search use case (no ViewModel `searchText` seeding)
- [x] Fix MainActor isolation compile error for UI-test stub factory (historical: `StubGamesRepository.forUITests()`)
- [x] Cleanup batch: backtick GWT test names, AccessibilityIdentifiers SPM, UI POM, C API key (not Info.plist), flatten Infrastructure, lazy AppContainer, inline UI-test stub, OptimizedAsyncImage keep + README note
- [x] Fold API key + `DEVELOPMENT_TEAM` into gitignored `Config.xcconfig`; track `Config.xcconfig.sample`; remove `Secrets.xcconfig`
- [x] Shared `httpClient` + interceptors as lazy vars on `AppContainer` (reuse for future repositories)

- [x] Commit cleanup batch on `develop` (flatten, a11y SPM, POM pages, Config.xcconfig sample, shared httpClient)
- [x] `AppContainer.Overrides` + thin UITest bootstrap (`UITestSupport.makeOverrides()`)
- [x] POM scaffolding: `AppLauncher`, fluent page nav, split UITest files, adaptations doc
- [x] Async XCTWaiter page-object waits (`waitForExistenceAsync`, parallel `async let`); ~14% faster UI suite (70.3s → 60.4s)
- [x] Game Details UI coverage: content chips/description/website + error/Retry via `UITEST_FORCE_DETAILS_FAILURE`
- [x] `AppContaining` + production `AppContainer` + DEBUG `DebugAppContainer` (wrap + Overrides)
- [x] Debug `Overrides` use-case-only (no repository field); UITestSupport injects stub use cases
- [x] UI-test scenarios via single `UITEST_CONFIG` JSON with per-screen nested `UITestConfiguration` (`gamesList` / `gameDetails`)
- [x] UI-test stubs at inbound use-case layer (`StubSearchGamesUseCase` / `StubGetGameDetailsUseCase`); removed `StubGamesRepository`
- [x] Canned `(page, searchText)` stub map + Codable `GameSummaryFixture` responses; shared stubs for `#Preview`
- [x] Details stub per-id outcome queues; drop search `default` + `failuresRemaining`
- [x] SwiftUI section/row factoring: extract `View` structs (narrow inputs); document rule in adaptations + hexagonal skill
- [x] Spanish localization (`es`): `GamesLibrary/Resources/` (`Assets.xcassets`, `Localizable.xcstrings`); SwiftUI literals + translator comments; UI tests stay on accessibility identifiers
- [x] Extract reusable helpers into local packages: `IOSConveniences` (`ViewLoadState`, `HTMLText` Foundation scanner, `HTTPConveniences`), `SwiftUIComponents`, `XCUITestPOM`
- [x] Agent skill `save-changes` (`/save-changes`): update memory, commit, and push
- [x] Per-screen UI folders: screen view + ViewModel at feature root; section/row views in `Subviews/`
- [x] Split `RootView` into `AppRootView` (app shell) + `GamesNavigationView` (games stack); `Route.gamesList` in `AppCoordinator.build`
- [x] Coordinator via `.environment` from `AppRootView`; feature views read `@Environment(AppCoordinator.self)`
- [x] `UITestConfiguration` stub tables as native JSON dicts (`gamesList.responses` / `gameDetails.responses`); drop wrapper row types
- [x] Shared-process UI tests: one launch (`UITESTING=1`), runtime apply via deep-link URL + ready marker, mutable stub host
- [x] Slim UI-test harness: inline 1×1 ready marker; drop unused apply-trigger + pasteboard fallback
- [x] `GamesLibraryUITestKit` local package; DEBUG glue in `GamesLibrary/App/UITest/`; documented reload flow in adaptations
- [x] API key via gitignored `Secrets.swift` (+ sample); `Config.xcconfig` holds `DEVELOPMENT_TEAM` only; drop C/bridging
- [x] Games list rows use `NavigationLink(value: Route.details)` for disclosure indicator; path-driven navigation via existing `navigationDestination`
- [x] Fix shared-process UI tests: `popToRoot` Back-button query no longer throws after popping to Games Library
- [x] Nested POM subviews (`GamesListPage.GameRow`, `GameDetailsPage.Header`/`Content`); row child accessibility IDs; opt-in `requireAsync` + `ElementRequirement` in `XCUITestPOM`
- [x] Extract publishable **`AsyncSharedTestingKit`** (`ASTK` / `ASTKApp` / `ASTKXCTest`): shared-process UI testing + async POM; replace `XCUITestPOM`; slim `AccessibilityIdentifiers` + `GamesLibraryUITestKit`; 11 package tests + 8 UI tests green (~62s)
- [x] Publish ASTK to GitHub ([illescasDaniel/astk](https://github.com/illescasDaniel/astk) @ 0.1.0); GamesLibrary links remote package; local copy at sibling `../astk`
- [x] Reliable DEBUG test-host detection via `UnitTestProcessInfo` (`XCTestBundlePath` / `XCTestConfigurationFilePath` + `IS_TESTING` on test scheme)
- [x] Colocate UI-test session generation in `UITestAppContent`; drop legacy launch-env `uitestFromLaunchEnvironment()` path
- [x] Colocate shared-process UI-test bootstrapping in `UITestAppContent` (`scenarioHost`, coordinator, container); slim `DebugAppContainer` to `Overrides` only (no stored `scenarioHost`)
- [x] Private app content shells: Release `AppContent`, DEBUG `DebugAppContent`; `@main` structs route only (no coordinator `@State` in `App`)
- [x] Debug-only `Info-Debug.plist` for UI-test deep link scheme; Release uses generated Info.plist (no `gameslibrary-uitest` URL type)
- [x] README documents ASTK (shared-process launch + async POM) and current stack
- [x] Merge `develop` into `main`

### Open

- [ ] Continue hexagonal/SDD feature work on `develop`
