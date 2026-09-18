# Decisions

_Log of significant technical, structural, or dependency choices. Newest first._

## 2026-09-18 — API key in gitignored Secrets.swift

- **Context:** API key was injected via C/`OTHER_CFLAGS` from `Config.xcconfig`, requiring a bridging header. That avoided Info.plist leakage but added complexity without real security (literal still recoverable from the binary).
- **Decision:** Move the API key to gitignored `GamesLibrary/Configuration/Secrets.swift` (`enum Secrets { static let apiKey }`); track `Secrets.swift.sample`. Slim `Config.xcconfig` to `DEVELOPMENT_TEAM` only. Delete `APIKey.c`/`APIKey.h`/bridging header and clear `SWIFT_OBJC_BRIDGING_HEADER`.
- **Rationale:** Same honesty about client-side extractability; far less machinery; signing stays in xcconfig where build settings belong.

## 2026-09-18 — Extract DEBUG UI-test kit to `GamesLibraryUITestKit`

- **Context:** Shared-process UI test files (`UITest*`) lived in `GamesLibrary/App/` and polluted production navigation (`RootView`, `AppCoordinator.uiTestSessionGeneration`).
- **Decision:** Local package `GamesLibraryUITestKit` holds stubs, scenario host, apply handler, runtime, and `UITestHarnessView`. App keeps thin glue under `GamesLibrary/App/UITest/` (`UITestAppContent`, delegate, `DebugContainerOverrides`). `DebugGamesLibraryApp` owns `@State uiTestSessionGeneration` + `@State scenarioHost` and wraps `RootView` only when UI testing.
- **Rationale:** Template-scale separation: production shell stays clean; DEBUG kit is linkable from tests/previews; session reset state lives in the DEBUG entry point, not navigation coordinator.

## 2026-09-18 — Shared-process UI tests via pasteboard + DEBUG deep link

- **Context:** Each UI test relaunched the app with `UITEST_CONFIG` in launch environment. That isolates scenarios but scales poorly (~100 tests → ~100 cold launches). This repo is a template for larger apps.
- **Decision:** Launch once with `UITESTING=1`. Each test calls `AppLauncher.apply(configuration:)`: pop to list if needed, open `gameslibrary-uitest://apply?config=<base64url JSON>` via `XCUIDevice.shared.system.open`, wait for `AccessibilityIdentifier.UITest.ready(sessionGeneration:)`. DEBUG `UITestScenarioHost` owns mutable stub use cases; apply resets navigation and bumps `sessionGeneration` so `RootView` recreates the list ViewModel. Named pasteboard + `uitest-apply-trigger` remain as DEBUG manual fallback; legacy env-only `UITEST_CONFIG` (without `UITESTING`) still works for one-shot launches.
- **Rationale:** Launch environment cannot change after `launch()`; URL query carries config without cross-process pasteboard; `XCUIApplication.open` is unreliable after in-app navigation — `XCUIDevice.shared.system.open` + pop-to-root fixes delivery. Apply resets nav, replaces stub tables, bumps `sessionGeneration`, and `.id(generation)` recreates the list ViewModel. Serial test plan required (no parallel shared process). See adaptations doc § Shared-process UI tests for the full flow.

## 2026-09-18 — Extract shared helpers into three local Swift packages

- **Context:** GamesLibrary had reusable UI-state, HTML stripping, HTTP interceptors, SwiftUI chrome, and XCUITest POM helpers inlined in the app. Other similar iOS apps cannot import them until they live as packages.
- **Decision:** Keep packages inside this repo (not GitHub yet). Split into `IOSConveniences` (products `ViewLoadState`, `HTMLText`, `HTTPConveniences`), growable `SwiftUIComponents` (`LoadingView`, `capsuleChipStyle()`, `onNearBottom`), and UI-test-only `XCUITestPOM`. Do not change HTTIES: interceptors live in `HTTPConveniences` (query-item interceptor + response logger with a `(String) -> Void`). HTML stripping is a Foundation-only scanner — no UIKit / `NSAttributedString`.
- **Rationale:** XCTest must not enter the app link graph; SwiftUI chrome should grow without pulling ViewModels or HTTP; ViewModels import Foundation-only `ViewLoadState`. The HTML importer required UIKit and was not thread-safe; a scanner matches the “readable visible text” contract and `swift test` on the host.

## 2026-09-17 — SwiftUI sections/rows are `View` structs, not computed `some View`

- **Context:** List/details screens factored UI via `private var` / `@ViewBuilder` helpers; Apple’s SwiftUI guidance says those share the parent’s invalidation boundary.
- **Decision:** Extract list rows, thumbnails, and details sections into dedicated `struct …: View` types with narrow value inputs (screen ViewModels stay on the parent). Document the extract-vs-computed rule of thumb in `GamesLibrary-adaptations.md` and `hexagonal-ios` skill.
- **Rationale:** Separate `View` types are SwiftUI’s invalidation unit; computed helpers only organize code. Matches Apple `swiftui-specialist/references/structure.md` without inventing per-section ViewModels.

## 2026-09-17 — Details preview seeds success; stubs stay MainActor

- **Context:** After fixing port shadowing, details `#Preview` could still sit on loading: SwiftUI often cancels `.task` after `.loading` is set. List preview worked because its stub returns before cancel races. `xcuserdata` was tracked despite `.gitignore`.
- **Decision:** Stubs match test mocks (`@MainActor`, no `nonisolated` port methods). ViewModel keeps existing `.success` while refreshing; Preview calls `previewSucceeding(_:)`. `git rm --cached` xcuserdata (private scheme order hints only; shared schemes live in `xcshareddata`).
- **Rationale:** Same MainActor path as unit-test mocks; Preview first frame is stable; user-specific Xcode state stays untracked.

## 2026-09-17 — Silence stub StrictMemorySafety warnings

- **Context:** `nonisolated(unsafe)` queue storage triggered `#StrictMemorySafety` warnings.
- **Decision:** `StubGetGameDetailsUseCase` stores outcome queues in `Mutex`. (Tried `type: .static` package products for sysroot noise; reverted — duplicates when app + tests both link the product.)
- **Rationale:** Mutex is the safe concurrent store without unsafe access.

## 2026-09-17 — GameDetailsViewModel must not shadow the use-case property

- **Context:** Preview “worked” only with `initialState: .success` because `func getGameDetails(id:)` shadowed `let getGameDetails: any GetGameDetailsUseCasePort`, so `try await getGameDetails(id:)` recursed and never called the port (infinite loading / cancel).
- **Decision:** Rename the stored port to `getGameDetailsUseCase` (same idea as list: `searchGames` vs `searchGame`). Drop preview `initialState` overload; restore normal `.loading` → fetch → success.
- **Rationale:** Matches list naming discipline; exposes a real bug that seeded state was masking.

## 2026-09-17 — Stub use cases are canned response maps only

- **Context:** Search stub still had a `default` fallback; details stub synthesized summaries and used a global `failuresRemaining` counter.
- **Decision:** `StubSearchGamesUseCase` is only `[SearchStubKey: [GameSummary]]` (miss → `[]`; `.constant` registers `(1, "")`). `StubGetGameDetailsUseCase` is `[GameID: [DetailsStubOutcome]]` queues (miss → error; `.constant` registers one success). Config mirrors this with `gamesList.responses` / `gameDetails.responses` (`DetailsOutcome`, `GameDetailsFixture`); Retry via `.failingThenSucceeding()`. Drop `failuresRemaining` and search `default`.
- **Rationale:** Stubs look up programmed replies only; UI tests and previews share the same seams without fake domain logic.

## 2026-09-17 — Stub search use case is a canned `(page, searchText)` map

- **Context:** `StubSearchGamesUseCase` reimplemented trim/filter/pagination after moving UI stubs to the inbound port; UI tests only needed empty vs default, and SwiftUI previews each had a private `PreviewMock*UseCase`.
- **Decision:** Stub takes `[SearchStubKey: [GameSummary]]` (`page` + `searchText`; tuple keys aren’t Hashable here) plus a `default` fallback (`.constant` ignores inputs). `UITestConfiguration.GamesList.responses` carries Codable `SearchResponse` / `GameSummaryFixture` (no Core types in AccessibilityIdentifiers); `nil` → `(1, "")` fixtures in `UITestSupport`. Drop `emptyResults` in favor of `.empty` / explicit responses. Previews use the same DEBUG stubs.
- **Rationale:** Stubs look up canned replies instead of faking domain logic; JSON fixtures stay shared and Core-free; one stub type for UI tests and `#Preview`.

## 2026-09-17 — AppContainer init injects HTTP handler, cache, request interceptors

- **Context:** Only `responseInterceptors` were init-injected; `URLSession.shared`, production `URLCache`, and API-key request interceptors were hard-wired lazy locals, so Debug/tests could not replace the HTTP stack at construction.
- **Decision:** `AppContainer` takes `urlCache` (`nil` → default image cache), `httpDataRequestHandler` (default `URLSession.shared`), `requestInterceptors` (`nil` → API-key interceptor), plus existing `responseInterceptors`. `DebugAppContainer` passes `logger` and `overrides.urlCache` into production and always forwards `configureSharedURLCache()`.
- **Rationale:** Same construction-time injection pattern as response logging; keeps the graph private while allowing full HTTP/cache substitution without a parallel subgraph.

## 2026-09-17 — HTTP response logging via DebugAppContainer → AppContainer init

- **Context:** `HTTPResponseLoggerInterceptor` lived on `AppContainer` behind `#if DEBUG`, mixing debug wiring into the production composition root. Stripping `private` so Debug can mutate the graph would not help: lazy `httpClient` / repository are wired once at first use.
- **Decision:** `AppContainer` takes `responseInterceptors` in `init` (default `[]`, no `#if DEBUG`). `DebugAppContainer` always passes `[HTTPResponseLoggerInterceptor]`. Keep intentional internal seams (`makeSearchGamesUseCase` / `makeGetGameDetailsUseCase`); do not open the whole graph.
- **Rationale:** Debug owns debug behavior; Release stays empty interceptors without compile flags; injection at construction avoids the old parallel networking subgraph.

## 2026-09-17 — UI tests stub inbound use cases (not repository)

- **Context:** UI tests wrapped `StubGamesRepository` in real use cases; Overrides already only replace inbound ports, so the outbound stub was an extra seam.
- **Decision:** DEBUG `StubSearchGamesUseCase` / `StubGetGameDetailsUseCase` (+ `UITestFixtures`) map from `UITestConfiguration`; delete `StubGamesRepository`. Slim `gameDetails` config to `failuresRemaining` only.
- **Rationale:** UI tests exercise ViewModels against inbound ports; repository stubs belong in adapter/unit tests. Matches use-case-only Overrides.

## 2026-09-17 — UI-test scenarios via single UITEST_CONFIG JSON

- **Context:** Empty-list and details-failure UI tests each needed a dedicated `UITEST_*` env key; more stub scenarios would proliferate keys and `AppLauncher` parameters.
- **Decision:** Share `UITestConfiguration: Codable` in AccessibilityIdentifiers with **per-screen nested configs** (`gamesList`, `gameDetails`, …). `AppLauncher` encodes it to `UITEST_CONFIG`; DEBUG `UITestSupport` treats presence of that env key as the UI-test gate, decodes, and maps to stub use-case Overrides. Malformed JSON `preconditionFailure`s in DEBUG.
- **Rationale:** One env blob grows by screen without new keys; typed encode/decode stays shared between app and UITests; Core entities stay out of the identifiers package. No separate `-UITesting` launch argument.

## 2026-09-17 — Response logging stays on AppContainer; Overrides drop interceptors

- **Context:** `responseInterceptors` on `DebugAppContainer.Overrides` forced a parallel HTTP→repository stack (`ownsCustomNetworking`) just to attach a log interceptor.
- **Decision:** Remove interceptor overrides and that subgraph. `AppContainer` installs `HTTPResponseLoggerInterceptor` under `#if DEBUG`. Debug Overrides remain use cases + `urlCache` + `logger` only.
- **Rationale:** Logging is not a test seam; duplicating networking for it was accidental complexity.

## 2026-09-17 — Debug Overrides are use-case-only (no repository)

- **Context:** Overrides allowed both repository and use-case replacement, which duplicated seams and complicated `DebugAppContainer` resolution.
- **Decision:** `DebugAppContainer.Overrides` only replaces inbound ports (`searchGamesUseCase`, `getGameDetailsUseCase`) plus infra (`urlCache`, `logger`). UI tests inject stub use cases from `UITestSupport.makeOverrides()`.
- **Rationale:** One override layer matching what ViewModels depend on; simpler forwarding; fixtures stay an implementation detail of the test bootstrap.

## 2026-09-17 — AppContaining + DebugAppContainer (wrap production)

- **Context:** `#if DEBUG` Overrides inside `AppContainer` were noisy; GamesList `#Preview` double-mocked a use case and an incompatible repository override for the coordinator.
- **Decision:** `AppContaining` exposes only ViewModel factories; production-clean `AppContainer`; DEBUG-only `DebugAppContainer` wraps production and applies `Overrides` (use cases, repository, cache, logger, response interceptors), forwarding when unset. `configureSharedURLCache` stays on concrete types. Live DEBUG uses `.debugDefaults()` for response logging. Previews: screen-only = mock inbound port; navigable = single `DebugAppContainer` seam. UI tests keep repository stubs via `UITestSupport`.
- **Rationale:** UI/navigation only need ViewModels; use-case/HTTP seams stay private to DI so Debug can patch freely without widening the protocol.

## 2026-09-17 — Details error a11y via root id swap + fail-once stub

- **Context:** `ContentUnavailableView` inherits the parent `accessibilityIdentifier` and drops child IDs, so a dedicated Retry id never appears in the hierarchy. Details failure UI tests also need a deterministic stub seam.
- **Decision:** Swap the details root identifier to `GameDetails.error` while in `.error` (same pattern as list empty state). Page object locates Retry as the **button** matching that error id. `UITEST_FORCE_DETAILS_FAILURE=1` sets `StubGamesRepository.detailsFailuresRemaining = 1` so the first details call fails and Retry succeeds. Ignore `CancellationError` in `GameDetailsViewModel` so cancelled `.task` restarts do not paint a false error.
- **Rationale:** Matches proven list empty-state a11y; keeps UI tests free of visible copy; one launch env covers both error presence and Retry recovery without sticky forever-fail.

## 2026-09-17 — DEBUG-only AppContainer.Overrides + responseInterceptors

- **Context:** Overrides existed in Release (convention only that production never passed them); response interceptors were hard-wired separately from the override bag.
- **Decision:** Wrap `Overrides` and the `overrides:` init/accessors in `#if DEBUG`. Release has only `AppContainer(environment:)`. Add `responseInterceptors: [any HTTPResponseInterceptor]?` to `Overrides` (`nil` = DEBUG default logger interceptor; non-`nil` including `[]` = explicit replacement).
- **Rationale:** Compile-time guarantee that production cannot inject test/preview seams; grow the override surface by fields consistently with repository/cache/logger.

## 2026-09-17 — Async throwing page-object element accessors

- **Context:** Page objects exposed raw `XCUIElement` vars that were unloaded until a separate `waitFor*` call; easy to tap/assert too early.
- **Decision:** Element accessors are `var …: XCUIElement { get async throws }` (or query) that wait then return or throw `UITestElementError`. UI tests are `async throws` and use `try await list.screen` / `try await details.screen`. Absence uses `requireNo…` / `requireAbsence`. Shared helpers in `XCUIElement+Require`.
- **Rationale:** Unloaded elements stay private; failure is a throw (natural XCTest `async throws` failure) instead of `XCTAssertTrue(wait…)`.

## 2026-09-17 — AppContainer.Overrides + POM UI-test layout

- **Context:** Dual `AppContainer` inits and ad-hoc override optionals would not scale; UI tests lived in one class as screens grow.
- **Decision:**
  - Single `AppContainer(environment:overrides:)` with nested `Overrides` (`gamesRepository`, `urlCache`, `logger`; `.none` for production). DEBUG `UITestSupport.makeOverrides()` maps launch args/env → overrides; `@main` stays thin.
  - POM: `AppLauncher` for launch; one page object per screen with navigate actions returning the next page; split `GamesListUITests` / `GameDetailsUITests`. Documented in `GamesLibrary-adaptations.md`.
- **Rationale:** Explicit composition root without a DIC; override surface grows by fields not inits; UI tests scale by screen without raw identifiers or ViewModel seeding.

## 2026-09-17 — Local config lives in gitignored Config.xcconfig

- **Context:** API key lived in a separate gitignored `Secrets.xcconfig` included by tracked `Config.xcconfig`; signing had no checked-in `DEVELOPMENT_TEAM`.
- **Decision:** Fold `API_KEY` and `DEVELOPMENT_TEAM` into `Config.xcconfig` (gitignored). Track `Config.xcconfig.sample` as the template. Remove `Secrets.xcconfig` / `Secrets.xcconfig.sample`. Keep C/`OTHER_CFLAGS` injection of the API key.
- **Rationale:** One local config file for machine-specific values; sample documents required keys without shipping secrets or a dummy xcconfig in the app bundle.

## 2026-09-17 — Cleanup: a11y package, C API key, flatten folders, keep OptimizedAsyncImage

- **Context:** Batch cleanup — share accessibility IDs with UI tests without dual-compile; stop shipping API key in Info.plist; drop redundant `Infrastructure/` wrapper; reconsider OptimizedAsyncImage vs SwiftUI `AsyncImage` caching.
- **Decision:**
  - Local SPM `GamesLibraryAccessibilityIdentifiers` (product `AccessibilityIdentifiers`) linked by app + UITests; DEBUG-only `UITestSupport` in `App/`; launch env key in package as `UITestEnvironment`.
  - API key via C + `OTHER_CFLAGS` from `Secrets.xcconfig` (not Info.plist). Document that the literal remains easily recoverable; prefer BFF for real products.
  - Promote former `Infrastructure/` children to app root; keep thin `App/`.
  - Keep OptimizedAsyncImage primarily for ImageIO `targetSize` downsampling (not for lack of AsyncImage caching on iOS 27+).
  - Lazy production wiring in `AppContainer`; inline UI-test stub setup (removed `forUITests()`).
- **Rationale:** Cleaner test contracts, less accidental secret exposure in plists, flatter app tree, honest security caveats, keep memory wins from downsampling.

## 2026-09-17 — @MainActor on StubGamesRepository.forUITests()

- **Context:** With `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `UITestSupport` is MainActor-isolated. `StubGamesRepository` is `@unchecked Sendable`, so `forUITests()` was treated as nonisolated and could not read `shouldForceEmptyResults`. Marking the env key/`shouldForceEmptyResults` `nonisolated` failed because stored properties remain MainActor under default isolation.
- **Decision:** Keep `UITestSupport` fully MainActor; mark `StubGamesRepository.forUITests()` `@MainActor` (only called from `DebugGamesLibraryApp.init`).
- **Rationale:** Matches call-site isolation without string duplication or `nonisolated(unsafe)`. *(Superseded later same day: `forUITests()` removed; empty-results check inlined in `DebugGamesLibraryApp`.)*

## 2026-09-16 — Empty UI-test results via configurable StubGamesRepository

- **Context:** `AppContainer.makeGamesListViewModel()` seeded `searchText` under `#if DEBUG` when `UITEST_FORCE_EMPTY_RESULTS=1`, duplicating logic already expressible by the outbound stub.
- **Decision:** Make `StubGamesRepository` a mutable class configured at the composition root (`StubGamesRepository.forUITests()`). Empty-results UI tests pass empty `games`; `AppContainer` ViewModel factories stay free of UI-test conditionals. Removed magic query string / `noResultsSearchQuery`.
- **Rationale:** Hexagonal composition root owns test doubles; presentation factories should not know about XCUITest launch env. Mutable stub data allows future scenarios without ViewModel hacks.

## 2026-09-16 — Screen-owned ViewModels with @State

- **Context:** List VM lived on `RootView` (`@State`); both screens used `@Bindable`. List used `onAppear` + flag after a UI-test workaround replaced `.task`.
- **Decision:** Screens own injected ViewModels via `@State private var viewModel` + explicit `init`. `AppContainer` / `AppCoordinator` still **construct** at the call site; `@Bindable` reserved for coordinator path bindings only. List initial load uses `.task`. Removed empty `GamesLibraryUITestsLaunchTests` (launch smoke in `GamesLibraryUITests`).
- **Rationale:** Matches Apple Observation ownership (screen = owner, child = `@Bindable` only when needing `$`). Makes screens movable as a large-app template; visit-scoped VM lifetime. Constructor injection from hexagonal DI unchanged.

## 2026-09-16 — GamesLibraryCore declares macOS + iOS platforms

- **Context:** `Package.swift` showed `-Wincompatible-sysroot` (macOS 27.0 SDK + `arm64-apple-ios18.0.0-simulator`) when SourceKit-LSP indexed the iOS-only package on the Mac host.
- **Decision:** Keep `.iOS("18.0")` and add `.macOS("14.0")` so the host platform is supported. Core remains Foundation-only; app still builds for iOS.
- **Rationale:** SourceKit-LSP prefers the host triple when the package supports it, which pairs macOS SDK with a macOS target. Matches `swift test` from `GamesLibraryCore/`.

## 2026-09-15 — Vendor Xcode 27 agent skills into `.cursor/skills/`

- **Context:** Xcode 27 ships official Agent Skills (`swiftui-specialist`, `swiftui-whats-new-27`, `modernize-tests`, App Intents, …). Cursor discovers project skills from `.cursor/skills/<name>/SKILL.md`.
- **Decision:** Export with `xcrun agent skills export --output-dir .cursor/skills` and keep the 10 Apple skill folders next to the project skills. Refresh via a temp dir + `cp` so `--replace-existing` cannot wipe `sdd-feature` / `hexagonal-ios` / `playbooks`.
- **Rationale:** Apple’s SwiftUI/SDK guidance is authoritative for implementation details; hexagonal + SDD still own architecture. Documented in `AGENTS.md`.

## 2026-09-14 — Agent memory bank (srxy protocol)

- **Context:** Agents lose branch-local context across sessions and worktrees. srxy already uses a tracked `memory/` bank plus an always-on Cursor rule.
- **Decision:** Replicate srxy's protocol here: `memory/progress.md`, `memory/activeContext.md`, `memory/decisions.md`, `.cursor/rules/agent-memory.mdc` (`alwaysApply: true`), and `.gitattributes` `memory/decisions.md merge=union`. Memory is git-tracked per branch, not local scratch.
- **Rationale:** Same hand-off as srxy — session init reads active context + progress; decisions are append-only and union on merge. Keeps GamesLibrary AI-ready without inventing a second system.

## 2026-09-14 — GamesLibraryCore as a local Swift package

- **Context:** Playbook default is a `Core/` folder inside the app target, which cannot enforce import isolation at compile time.
- **Decision:** Domain, ports, and use cases live in **`GamesLibraryCore`**, a local Swift package. The app target is the outside: inbound/outbound adapters, `AppContainer`, `AppCoordinator`. Core may import Foundation only — no SwiftUI, SwiftData, UIKit, HTTIES, BetterLogger, TTLCache, DIC, or DTOs.
- **Rationale:** Compile-time isolation matches hexagonal "inside vs outside" better than a folder convention. ViewModels depend on inbound ports (`*UseCasePort`), never repositories or HTTP clients.

## 2026-09-14 — AppContainer + AppCoordinator (constructor injection)

- **Context:** Hexagonal playbook shows `.environment(AppContainer)`; senior iOS playbook prefers a coordinator for navigation.
- **Decision:** Combine both: `AppContainer` is the composition root (HTTP, cache, repository, use cases, ViewModel factories). `AppCoordinator` owns `NavigationPath` and route → view building. Views receive ViewModels via constructor injection; coordinator is passed via `.environment` for navigation only. `#Preview` mocks the inbound port, not the ViewModel.
- **Rationale:** Keeps DI explicit and testable while navigation stays out of ViewModels. Recorded in `docs/playbooks/GamesLibrary-adaptations.md`.

## 2026-09-14 — UI tests stub at the composition root

- **Context:** Live RAWG calls make XCUITests flaky (network, API key, catalog drift). Querying user-visible copy is unstable under localization.
- **Decision:** Launch argument `-UITesting` wires `StubGamesRepository` in `AppContainer`. UI tests use `AccessibilityIdentifier` constants (shared compile unit with the app), never duplicated raw strings or visible copy.
- **Rationale:** Deterministic flows without network; identifiers are the stable test contract. See adaptations → "UI test accessibility contract".

## 2026-09-14 — Demo security posture (no BFF / pinning / App Attest)

- **Context:** Senior iOS playbook recommends BFF, SSL pinning, and App Attest for production.
- **Decision:** This demo app calls RAWG directly with a client API key in `Secrets.xcconfig`. Do not add BFF, pinning, or App Attest unless a spec explicitly requests them.
- **Rationale:** Acceptable for a learning/demo app; those controls are out of scope until specified.

## 2026-09-14 — Formatting is a UI adapter concern

- **Context:** Dates, ratings, and HTML-stripped descriptions could live in Core or in views.
- **Decision:** Formatting (dates, ratings, HTML stripping) belongs in inbound UI adapters (`GameDetailsDisplayable`, `String+strippingHTML`). Domain entities stay unformatted.
- **Rationale:** Core stays presentation-agnostic; display strings can change without touching ports or entities.
