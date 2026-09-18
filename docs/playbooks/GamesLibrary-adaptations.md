# GamesLibrary — Playbook Adaptations

This project follows the senior iOS playbooks with these **intentional deviations**. Agents must prefer this file over generic playbook examples when they conflict.

## Module boundary

| Playbook default | GamesLibrary |
|------------------|--------------|
| `Core/` folder in app target | **`GamesLibraryCore`** local Swift package — compile-time isolation; Core cannot import HTTIES, SwiftUI, or app types |
| Generic `MyApp/` tree | App adapters live under `GamesLibrary/Adapters/` (no `Infrastructure/` wrapper; thin `App/` for `@main` + DEBUG UI-test support) |

## Dependency injection & navigation

We combine both playbooks:

- **`AppContaining`** — ViewModel factory surface only (`makeGamesListViewModel` / `makeGameDetailsViewModel`); `AppCoordinator` / `RootView` depend on `any AppContaining`. Use cases and `configureSharedURLCache` stay on concrete containers.
- **`AppContainer`** — production implementation; wires HTTP, cache, repository, use cases, ViewModel factories. Init injects `urlCache`, `httpDataRequestHandler`, `requestInterceptors`, and `responseInterceptors` (sensible production defaults; `nil` request/cache = production API-key interceptor / default image cache). No Overrides, no `#if DEBUG`
- **`DebugAppContainer`** — DEBUG-only; wraps `AppContainer` and applies `Overrides` when set (**use cases**, `urlCache`, `logger`). Passes logger, optional `urlCache`, and `HTTPResponseLoggerInterceptor` into `AppContainer` at construction. No repository override bag. Forwards to production when nothing relevant is overridden. No DIC / service locator.
- **`AppCoordinator`** — owns `NavigationPath` and route → view building
- **Constructor injection** — ViewModels receive inbound ports in `init`; views receive ViewModels from the coordinator/container

The Hexagonal playbook shows `.environment(AppContainer)`; here we inject ViewModels directly and pass the coordinator via `.environment` for navigation only.

DEBUG entry (`DebugGamesLibraryApp`): shared-process UI tests → `UITestAppContent` + `GamesLibraryUITestKit`; legacy env-only → `DebugAppContainer.Overrides.uitestFromLaunchEnvironment()`; otherwise plain `DebugAppContainer()`. Release `@main` uses `AppContainer()` only.

### Preview seams

- Prefer one `DebugAppContainer(overrides:)` and take ViewModels from the container (list and details). Pass the same instance to `AppCoordinator` when navigation is needed. Do not also hand-build a ViewModel with a different mock.
- Details `#Preview` may call `previewSucceeding(_:)` so the first frame is not a stuck loading overlay if SwiftUI cancels `.task`; the stub override still handles Retry.

### SwiftUI view factoring

A `View` type is SwiftUI’s invalidation boundary. `private var …: some View` / `@ViewBuilder` helpers on the parent are inlined into that parent’s body — they do **not** create a separate update scope. Prefer Apple’s structure guidance (`.cursor/skills/swiftui-specialist/references/structure.md`).

**Extract a `struct …: View` when any of these hold:**

- Named UI **section** (header, chips, description, empty/error overlay)
- **List / ForEach row** content
- Subtree that should **skip updates** when sibling state changes
- Helper that already takes explicit parameters — that is already halfway to a struct

**Keep as `private var` / small `@ViewBuilder` when:**

- Roughly 5–15 lines with no independent state story
- Pure visual constant (e.g. a placeholder glyph)

**Do not:** invent ViewModels per section; pass the screen ViewModel into leaves “for convenience”; extract every 3-line snippet into its own file. Section/row structs take **narrow value inputs** (and callbacks), not the full `@Observable` ViewModel. Screen views own `@State` ViewModels and compose sections.

## Security (client API key)

Per the Senior playbook, production apps should use BFF, SSL pinning, and App Attest. **This demo app intentionally:**

- Calls RAWG directly with a client API key (acceptable for learning/demo; not production)
- Embeds that key in gitignored `GamesLibrary/Configuration/Secrets.swift` (tracked template: `Secrets.swift.sample`; avoids Info.plist leakage; **still trivially extractable from the binary**)
- Keeps `DEVELOPMENT_TEAM` in gitignored `Config.xcconfig` (signing only)
- Does not implement SSL pinning or App Attest

Do not treat the Swift string literal as secure storage. Prefer a backend that holds secrets and authenticates the client for any real product.

## Testing

| Playbook | GamesLibrary |
|----------|--------------|
| Unit tests from BDD (`Swift Testing`) | ViewModels + use cases in `GamesLibraryTests` and `GamesLibraryCoreTests` |
| UI tests (`XCTest`) | `GamesLibraryUITests` — **shared-process**: launch once with `UITESTING=1`, apply each scenario via DEBUG deep link (`gameslibrary-uitest://apply?config=…`); run serially (`parallelizable: false` in test plan) |
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
| Launch | `GamesLibraryUITests/Support/AppLauncher` | `ensureLaunched()` once; `apply(configuration:)` per scenario |
| DEBUG UI-test kit | `GamesLibraryUITestKit/` (local package) | Stubs, scenario host, apply handler, runtime |
| DEBUG app glue | `GamesLibrary/App/UITest/` | `UITestAppContent` shell, container override mapping |
| Tests | One `XCTestCase` per screen/feature | `async throws` tests; no raw identifiers |

Do **not** expose unloaded `XCUIElement` properties. Page accessors wait then return or throw:

```swift
let screen = try await details.screen
_ = try await list.gameRows
```

Missing elements throw `UITestElementError` (test fails via `async throws`). Absence checks use `requireNo…` / `requireAbsence`. Navigate actions return the next page (e.g. `try await list.tapGameRow(at:) -> GameDetailsPage`). Prefer `AppLauncher.applyGameDetails(index:)` when a test starts on details rather than composing list apply + tap. `ContentUnavailableView` inherits the parent accessibility identifier and drops child IDs — use a root id swap for error/empty (list empty state / details error) and query the Retry **button** via that same id. Cross-screen smoke can live in a small `NavigationUITests` when needed. New UI states = new fields on the matching per-screen nested config inside `UITestConfiguration` + stub mapping in `UITestSupport.makeStubTables(from:)` — never seed `ViewModel` state from the container.

### Shared-process UI tests (template-scale)

Large suites should **not** relaunch the app per test.

#### Why not launch environment per test?

`launchEnvironment` is fixed at `XCUIApplication.launch()`. Each test used to call `terminate()` + `launch()` with a new `UITEST_CONFIG` JSON blob — correct but slow (~100 tests → ~100 cold launches). Shared-process mode launches once with `UITESTING=1` and applies a fresh scenario at runtime.

#### How config is passed (test → app)

The scenario payload is a `UITestConfiguration` (Codable JSON). It travels in the **deep link query string**.

1. Test builds URL: `gameslibrary-uitest://apply?config=<base64url(JSON)>`
   - Encoding lives in `UITestConfiguration.makeApplyDeepLinkURL()` (`AccessibilityIdentifiers`).
2. Test opens URL via **`XCUIDevice.shared.system.open(url)`** — not `app.open(url)`.
   - After in-app navigation (e.g. details screen), `XCUIApplication.open` often fails to deliver the URL; `system.open` still does.
3. Test pops to the games list first (`AppLauncher.popToRoot`) so the app is in a known state before apply.
4. SwiftUI receives the URL via `.onOpenURL(perform: UITestRuntime.handleOpenURL)` on `UITestAppContent`.

#### How the app reloads (apply handler)

When `UITestRuntime.handleOpenURL` runs:

1. **Decode** — `UITestApplyHandler` reads `config` from the URL query.
2. **Reset navigation** — `AppCoordinator.resetNavigation()` clears `NavigationPath` (drops any details screen).
3. **Replace stubs** — `UITestScenarioHost.apply(configuration)` rebuilds mutable `StubSearchGamesUseCase` / `StubGetGameDetailsUseCase` tables and bumps `sessionGeneration`.
4. **Recreate UI** — `DebugGamesLibraryApp` holds `@State uiTestSessionGeneration`; `UITestAppContent` applies `.id(uiTestSessionGeneration)` on production `RootView`, forcing SwiftUI to destroy and recreate the list `@State` ViewModel (fresh `.task` → new stub data).
5. **Signal ready** — a 1×1 `Color.clear` overlay on `UITestAppContent` exposes `AccessibilityIdentifier.UITest.ready(sessionGeneration:)`; the test waits for the matching generation before querying page objects. Invisible on purpose so it does not show up in screenshots.

Both sides track generation: app bumps `UITestScenarioHost.sessionGeneration`; test increments its own counter in `AppLauncher` and waits for `uitest-ready-{N}`.

#### Test-side API

```swift
try AppLauncher.ensureLaunched()                          // once per suite: UITESTING=1
let list = try AppLauncher.apply(configuration: .default) // per test: URL apply + wait ready
let details = try await AppLauncher.applyGameDetails()    // apply + tap row
```

#### Constraints

- **Serial test plan only** — shared process is incompatible with parallel UI tests on one simulator.
- **DEBUG only** — `gameslibrary-uitest` URL scheme and ready marker are not used in Release.
- **Legacy path** — one-launch-per-test via launch-environment `UITEST_CONFIG` (without `UITESTING=1`) still works via `DebugAppContainer.Overrides.uitestFromLaunchEnvironment()`.

When SwiftUI `.searchable` text entry is unreliable in XCUITest, pass `UITestConfiguration(gamesList: .empty)` through `AppLauncher.apply` (canned `(1, "")` → `[]`). For custom rows / search / pagination, set `gamesList.responses` to `[SearchResponse]` with `GameSummaryFixture` (mapped to Core in DEBUG `UITestSupport`). For details Retry, use `gameDetails: .failingThenSucceeding()` (per-id outcome queue: `.failure` then `.success`). `nil` details responses → one success per list stub game. Previews share `StubSearchGamesUseCase` / `StubGetGameDetailsUseCase` (`.constant(...)`) via Overrides — do not seed `ViewModel.searchText` from the container.

## SDD source of truth

- Feature truth: `specs/<feature>/SPEC.md`
- Work tracking: Jira/Linear (external)
- Phase Gate Protocol: `AGENTS.md`
- Agent memory (per-branch): `memory/` — see [memory/README.md](../../memory/README.md)

## Skills & rules

- `.cursor/skills/sdd-feature/` — SDD workflow for this repo
- `.cursor/skills/hexagonal-ios/` — file placement and port naming
- `.cursor/skills/playbooks/` — when to read full playbooks vs this file
- `.cursor/skills/save-changes/` — update memory, commit, and push (`/save-changes`)
- Apple Xcode 27 skills (SwiftUI, Swift Testing, App Intents, …) live in `.cursor/skills/` next to the project skills — see `AGENTS.md` for the table and refresh command
- `.cursor/rules/sdd.mdc`, `hexagonal-ios.mdc`, `playbooks.mdc`, `agent-memory.mdc` — always-on constraints

When Apple’s SwiftUI/testing skills conflict with this file or hexagonal rules, **this file wins**.
