# GamesLibrary — Playbook Adaptations

This project follows the senior iOS playbooks with these **intentional deviations**. Agents must prefer this file over generic playbook examples when they conflict.

## Module boundary

| Playbook default | GamesLibrary |
|------------------|--------------|
| `Core/` folder in app target | **`GamesLibraryCore`** local Swift package — compile-time isolation; Core cannot import HTTIES, SwiftUI, or app types |
| Generic `MyApp/` tree | App adapters live under `GamesLibrary/Adapters/` (no `Infrastructure/` wrapper; thin `App/` for `@main` + DEBUG UI-test support) |

## Dependency injection & navigation

We combine both playbooks:

- **`AppContainer`** — composition root; wires HTTP, cache, repository, use cases, ViewModel factories
- **`AppContainer.Overrides`** — single optional bag (`gamesRepository`, `urlCache`, `logger`) for previews and UI tests. Prefer `AppContainer(overrides:)` over extra initializers; add new replaceable deps as fields on `Overrides`, not new inits. No DIC / service locator.
- **`AppCoordinator`** — owns `NavigationPath` and route → view building
- **Constructor injection** — ViewModels receive inbound ports in `init`; views receive ViewModels from the coordinator/container

The Hexagonal playbook shows `.environment(AppContainer)`; here we inject ViewModels directly and pass the coordinator via `.environment` for navigation only.

DEBUG entry (`DebugGamesLibraryApp`) stays thin: `UITestSupport.makeOverrides()` maps `-UITesting` / launch env → `AppContainer.Overrides`; production path uses `Overrides.none`.

## Security (client API key)

Per the Senior playbook, production apps should use BFF, SSL pinning, and App Attest. **This demo app intentionally:**

- Calls RAWG directly with a client API key (acceptable for learning/demo; not production)
- Embeds that key via C/`OTHER_CFLAGS` from gitignored `Config.xcconfig` (avoids Info.plist leakage; **still trivially extractable from the binary**)
- Does not implement SSL pinning or App Attest

Do not treat the C embedding as secure storage. Prefer a backend that holds secrets and authenticates the client for any real product.

## Testing

| Playbook | GamesLibrary |
|----------|--------------|
| Unit tests from BDD (`Swift Testing`) | ViewModels + use cases in `GamesLibraryTests` and `GamesLibraryCoreTests` |
| UI tests (`XCTest`) | `GamesLibraryUITests` — launch with `-UITesting` → `StubGamesRepository` (no live API); run serially (`parallelizable: false` in test plan) |
| SDD exploratory UI (MCP) | `.cursor/mcp.json` → `ios-simulator` (`ios-mcp-server`); see [ios-simulator-mcp.md](ios-simulator-mcp.md) |

### UI test accessibility contract

UI tests must **not** query user-visible copy (navigation titles, button labels, empty-state messages). Those strings change with localization and copy edits and are not a stable test contract.

Instead:

1. Define identifiers in the local **`AccessibilityIdentifiers`** package (`GamesLibraryAccessibilityIdentifiers`). Link it from the app and `GamesLibraryUITests` targets (UI test bundles cannot link the app module). One nested enum per screen; add IDs for loading / empty / error / content as states appear.
2. Apply them to screens and key states in SwiftUI views (`.accessibilityIdentifier(...)`).
3. In UI tests, reference `AccessibilityIdentifier` constants — never duplicate raw strings or query user-visible copy.
4. Prefer `app.element(matching:)` (descendants matching `.any`) over typed queries like `navigationBars["…"]` or `staticTexts["…"]`.

### Page Object Model (POM)

| Layer | Location | Rule |
|-------|----------|------|
| Shared IDs | `GamesLibraryAccessibilityIdentifiers` | Compile-time constants only |
| Page objects | `GamesLibraryUITests/Pages/` | One struct per screen; **async throwing** element accessors |
| Launch | `GamesLibraryUITests/Support/AppLauncher` | Shared `-UITesting` / env scenario API |
| Tests | One `XCTestCase` per screen/feature | `async throws` tests; no raw identifiers |

Do **not** expose unloaded `XCUIElement` properties. Page accessors wait then return or throw:

```swift
let screen = try await details.screen
_ = try await list.gameRows
```

Missing elements throw `UITestElementError` (test fails via `async throws`). Absence checks use `requireNo…` / `requireAbsence`. Navigate actions return the next page (e.g. `try await list.tapFirstGameRow() -> GameDetailsPage`). Cross-screen smoke can live in a small `NavigationUITests` when needed. New UI states (error, details failure) = new launch env keys + stub config via `UITestSupport.makeOverrides()` — never seed `ViewModel` state from `AppContainer`.

Launch argument `-UITesting` wires `StubGamesRepository` at the composition root so flows stay deterministic without network.

When SwiftUI `.searchable` text entry is unreliable in XCUITest, configure `StubGamesRepository` at the composition root via `UITestEnvironment.forceEmptyResultsKey` launch environment (`UITEST_FORCE_EMPTY_RESULTS=1` → empty stub games). DEBUG-only `UITestSupport` reads that env. Do not seed `ViewModel.searchText` from `AppContainer`.

## SDD source of truth

- Feature truth: `specs/<feature>/SPEC.md`
- Work tracking: Jira/Linear (external)
- Phase Gate Protocol: `AGENTS.md`
- Agent memory (per-branch): `memory/` — see [memory/README.md](../../memory/README.md)

## Skills & rules

- `.cursor/skills/sdd-feature/` — SDD workflow for this repo
- `.cursor/skills/hexagonal-ios/` — file placement and port naming
- `.cursor/skills/playbooks/` — when to read full playbooks vs this file
- Apple Xcode 27 skills (SwiftUI, Swift Testing, App Intents, …) live in `.cursor/skills/` next to the project skills — see `AGENTS.md` for the table and refresh command
- `.cursor/rules/sdd.mdc`, `hexagonal-ios.mdc`, `playbooks.mdc`, `agent-memory.mdc` — always-on constraints

When Apple’s SwiftUI/testing skills conflict with this file or hexagonal rules, **this file wins**.
