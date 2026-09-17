# Decisions

_Log of significant technical, structural, or dependency choices. Newest first._

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
