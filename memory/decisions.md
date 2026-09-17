# Decisions

_Log of significant technical, structural, or dependency choices. Newest first._

## 2026-09-17 — @MainActor on StubGamesRepository.forUITests()

- **Context:** With `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `UITestSupport` is MainActor-isolated. `StubGamesRepository` is `@unchecked Sendable`, so `forUITests()` was treated as nonisolated and could not read `shouldForceEmptyResults`. Marking the env key/`shouldForceEmptyResults` `nonisolated` failed because stored properties remain MainActor under default isolation.
- **Decision:** Keep `UITestSupport` fully MainActor; mark `StubGamesRepository.forUITests()` `@MainActor` (only called from `DebugGamesLibraryApp.init`).
- **Rationale:** Matches call-site isolation without string duplication or `nonisolated(unsafe)`.

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
