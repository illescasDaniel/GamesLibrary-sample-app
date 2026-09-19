# GamesLibrary — Playbook Adaptations

This project follows the senior iOS playbooks with these **intentional deviations**. Agents must prefer this file over generic playbook examples when they conflict.

## Module boundary

| Playbook default | GamesLibrary |
|------------------|--------------|
| `Core/` folder in app target | **`GamesLibraryCore`** local Swift package — compile-time isolation; Core cannot import HTTIES, SwiftUI, or app types |
| Generic `MyApp/` tree | App adapters live under `GamesLibrary/Adapters/` (no `Infrastructure/` wrapper; thin `App/` for `@main` + DEBUG UI-test support) |

## Dependency injection & navigation

We combine both playbooks:

- **`AppContaining`** — ViewModel factory surface only (`makeGamesListViewModel` / `makeGameDetailsViewModel`); held privately by `AppCoordinator` at the composition root. Use cases and `configureSharedURLCache` stay on concrete containers.
- **`AppRootView`** — app shell in `Navigation/` (today: hosts `GamesNavigationView`; future: `TabView` and other top-level chrome).
- **`GamesNavigationView`** — games feature `NavigationStack` + list root + details destinations under `Adapters/Inbound/UI/GamesList/` (feature root; not a screen subview).
- **`AppContainer`** — production implementation; wires HTTP, cache, repository, use cases, ViewModel factories. Init injects `urlCache`, `httpDataRequestHandler`, `requestInterceptors`, and `responseInterceptors` (sensible production defaults; `nil` request/cache = production API-key interceptor / default image cache). No Overrides, no `#if DEBUG`
- **`DebugAppContainer`** — DEBUG-only; wraps `AppContainer` and applies `Overrides` when set (**use cases**, `urlCache`, `logger`). Passes logger, optional `urlCache`, and `HTTPResponseLoggerInterceptor` into `AppContainer` at construction. No repository override bag, no stored scenario host — shared-process UI tests pass the host's mutable stub use cases through `Overrides` from `UITestAppContent`. Forwards to production when nothing relevant is overridden. No DIC / service locator.
- **`AppCoordinator`** — owns `NavigationPath`, holds `AppContaining`, and builds all routed views (`.gamesList`, `.details`, …)
- **Constructor injection** — ViewModels receive inbound ports in `init`; views receive ViewModels from the coordinator/container

The Hexagonal playbook shows `.environment(AppContainer)`; here we inject ViewModels directly and pass the coordinator via `.environment` for navigation only.

DEBUG entry (`DebugGamesLibraryApp`): shared-process UI tests (`UITESTING=1`) → `UITestAppContent()`; hosted unit tests → `EmptyView()`; otherwise `DebugAppContent()` (private shell: `DebugAppContainer` + coordinator + `AppRootView`). Release `@main` (`GamesLibraryApp`) → private `AppContent()` (`AppContainer` + coordinator + `AppRootView`).

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

**Folder layout per screen** (`Adapters/Inbound/UI/<Feature>/`):

- Screen view and ViewModel files at the feature folder root
- Extracted section/row views in `Subviews/`
- Feature navigation views (e.g. `GamesNavigationView`) stay at the feature root
- Cross-screen helpers stay in `ConvenienceViews/` / `Models/`

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
| Page objects | `GamesLibraryUITests/Pages/` | One struct per screen; nested `@MainActor` structs for subviews (e.g. `GamesListPage.GameRow`, `GameDetailsPage.Header`); **async throwing** element accessors (`XCTWaiter`) |
| Validation | `AsyncSharedTestingKit` (`ASTKXCTest`) | Opt-in `requireAsync(checks:in:)` with `ElementRequirement` (`.visible()`, `.visible(false)`, `.exists(false)`, `.tappable()`, `.nonEmptyText()`, …) |
| Launch | `GamesLibraryUITests/Support/AppLauncher` | Thin wrapper over `SharedProcessLauncher` — `ensureLaunched()` once; `apply(configuration:)` per scenario |
| DEBUG UI-test kit | `GamesLibraryUITestKit/` (local package) | App-specific stubs, `UITestScenarioHost`, `UITestSupport.makeStubTables` |
| Shared-process framework | `AsyncSharedTestingKit/` (`ASTK`, `ASTKApp`, `ASTKXCTest`) | Generic settings, URL transport, ready marker, session coordinator, POM helpers — see package README |
| DEBUG app glue | `GamesLibrary/App/UITest/` | `UITestAppContent` shell (inline `.id` + ready marker + `UITestSessionCoordinator`), container override mapping |
| Tests | One `XCTestCase` per screen/feature | `async throws` tests; no raw identifiers |

Do **not** expose unloaded `XCUIElement` properties. Page accessors wait via `XCTWaiter` then return or throw:

```swift
let row = try await list.gameRow(at: 0)
async let name = row.name
let nameElement = try await name
try await nameElement.requireAsync(
	identifier: AccessibilityIdentifier.GamesList.GameRow.name,
	checks: [.visible(), .nonEmptyText()],
	in: list.app
)
```

Page accessors wait for **existence only**. Stronger checks are **opt-in** via `requireAsync` so tests can resolve an element, perform an action, then assert a negative state later (e.g. `.exists(false)` after retry, `.visible(false)` when off-screen is enough).

| `ElementRequirement` | Meaning |
|---------------------|---------|
| `.exists()` / `.exists(false)` | In hierarchy / gone from hierarchy (replaces `requireAbsenceAsync`) |
| `.visible()` / `.visible(false)` | On screen (frame intersects viewport) / not on screen |
| `.visible(scroll: true)` | Scroll into view first, then on-screen check |
| `.tappable()` / `.tappable(false)` | Hittable / not hittable |
| `.enabled()` / `.enabled(false)` | Enabled / disabled |
| `.nonEmptyText()` / `.nonEmptyText(false)` | Label or value trimmed non-empty / empty |

Non-empty text checks assert structural content only — never compare against localized copy or fixture names. Container elements (e.g. platforms `ScrollView`) may have no label; use `.visible()` without `.nonEmptyText()` for those.

Nested row IDs are **relative** (`game-row-name`, …); query via `row.root.descendants(matching:)` so the same ID resolves per row. Navigate actions return the next page (e.g. `try await list.tapGameRow(at:) -> GameDetailsPage`). Prefer `async let` when asserting several independent elements. Prefer `AppLauncher.applyGameDetails(index:)` when a test starts on details. `ContentUnavailableView` inherits the parent accessibility identifier and drops child IDs — use a root id swap for error/empty and query the Retry **button** via that same id. New UI states = new fields on the matching per-screen nested config inside `UITestConfiguration` + stub mapping in `UITestSupport.makeStubTables(from:)` — never seed `ViewModel` state from the container.

### Shared-process UI tests (template-scale)

Large suites should **not** relaunch the app per test.

#### Why not launch environment per test?

`launchEnvironment` is fixed at `XCUIApplication.launch()`. Each test used to call `terminate()` + `launch()` with a new `UITEST_CONFIG` JSON blob — correct but slow (~100 tests → ~100 cold launches). Shared-process mode launches once with `UITESTING=1` and applies a fresh scenario at runtime.

#### How config is passed (test → app)

The scenario payload is a `UITestConfiguration` (Codable JSON). It travels in the **deep link query string**.

1. Test builds URL: `gameslibrary-uitest://apply?config=<base64url(JSON)>`
   - Encoding via ASTK `Encodable.makeApplyDeepLinkURL(settings:)`; scheme constant in `GamesLibraryUITestTransport`.
2. Test opens URL via **`XCUIDevice.shared.system.open(url)`** — not `app.open(url)`.
   - After in-app navigation (e.g. details screen), `XCUIApplication.open` often fails to deliver the URL; `system.open` still does.
3. Test pops to the games list first (`NavigationBarPopper.popTowardRoot`) so the app is in a known state before apply.
4. SwiftUI receives the URL via `.onOpenURL { sessionCoordinator.handleOpenURL($0) }` on `UITestAppContent`.

#### How the app reloads (apply handler)

When `UITestSessionCoordinator.handleOpenURL` runs (ASTKApp):

1. **Decode** — ASTK `UITestApplyHandler` reads `config` from the URL query.
2. **Reset navigation** — `AppCoordinator.resetNavigation()` clears `NavigationPath` (drops any details screen).
3. **Replace stubs** — `UITestScenarioHost.apply(configuration)` rebuilds mutable `StubSearchGamesUseCase` / `StubGetGameDetailsUseCase` tables and bumps `sessionGeneration`.
4. **Recreate UI** — `UITestAppContent` owns `@State uiTestSessionGeneration` and applies `.id(uiTestSessionGeneration)` on production `AppRootView`, forcing SwiftUI to destroy and recreate the list `@State` ViewModel (fresh `.task` → new stub data).
5. **Signal ready** — a 1×1 `Color.clear` overlay on `UITestAppContent` exposes `UITestReadyMarker.identifier(sessionGeneration:)`; the test waits for the matching generation before querying page objects. Invisible on purpose so it does not show up in screenshots.

Both sides track generation: app bumps `UITestScenarioHost.sessionGeneration`; `SharedProcessLauncher` increments its counter and waits for `uitest-ready-{N}`.

#### Test-side API

```swift
try AppLauncher.ensureLaunched()                          // once per suite: UITESTING=1
let list = try AppLauncher.apply(configuration: .default) // per test: URL apply + wait ready
let details = try await AppLauncher.applyGameDetails()    // apply + tap row
```

#### Constraints

- **Serial test plan only** — shared process is incompatible with parallel UI tests on one simulator.
- **DEBUG only** — `gameslibrary-uitest` URL scheme and ready marker are not used in Release.
- **Shared-process only** — UI tests launch with `UITESTING=1`; per-scenario config is applied at runtime via deep link, not relaunch `UITEST_CONFIG`.

When SwiftUI `.searchable` text entry is unreliable in XCUITest, pass `UITestConfiguration(gamesList: .empty)` through `AppLauncher.apply` (canned `(1, "")` → `[]`). For custom rows / search / pagination, set `gamesList.responses` to `[String: [GameSummaryFixture]]` keyed by `GamesList.searchKey(page:searchText:)` (e.g. `"1|"`, `"1|zelda"`; mapped to Core in `UITestSupport.makeStubTables`). For details Retry, use `gameDetails: .failingThenSucceeding()` (`[Int: [DetailsOutcome]]` per-id outcome queue: `.failure` then `.success`). `nil` details responses → one success per list stub game. Previews share `StubSearchGamesUseCase` / `StubGetGameDetailsUseCase` (`.constant(...)`) via Overrides — do not seed `ViewModel.searchText` from the container.

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
