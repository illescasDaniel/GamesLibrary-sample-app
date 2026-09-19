# GamesLibrary

Simple iOS app that presents a list of games using the [RAWG](https://rawg.io/apidocs) API.

Built with **Hexagonal Architecture**, **Spec-Driven Development (SDD)**, and **MVVM** as the UI presentation pattern. Requires **iOS 26.4+** and **Swift 6**.

## AI-ready

This repo is set up so humans and AI agents share the same source of truth:

| Piece | Where | Purpose |
|-------|-------|---------|
| Agent protocol | [AGENTS.md](AGENTS.md) | Phase gates for spec → ports → tests → implementation |
| Always-on rules | `.cursor/rules/` | Hexagonal boundaries, SDD, playbooks, **memory protocol** |
| Skills | `.cursor/skills/` | Project workflows (`sdd-feature`, `hexagonal-ios`, `playbooks`, `save-changes`) plus Apple Xcode 27 skills (`swiftui-specialist`, …) |
| Specs | `specs/<feature>/SPEC.md` | Feature truth (BDD acceptance criteria) |
| Memory bank | [memory/](memory/README.md) | Per-branch progress, session context, and decision log |
| MCP | [below](#mcp-tools-ai-assisted-development) | Simulator exploration and Xcode build/test/preview |

The memory bank is **tracked in git** so context follows the branch (same protocol as [srxy](https://github.com/illescasDaniel/srxy)). Agents read it at session start and update it at milestones — see [memory/README.md](memory/README.md).

## Architecture

### Hexagonal (Ports & Adapters)

Business logic lives in a local Swift package, **`GamesLibraryCore`**, with compile-time isolation from UI and I/O:

| Layer | Location | Responsibility |
|-------|----------|----------------|
| **Core** | `GamesLibraryCore/` | Domain entities, inbound/outbound ports, use cases |
| **Inbound adapters** | `GamesLibrary/Adapters/Inbound/` | SwiftUI views, `@Observable` ViewModels, formatters |
| **Outbound adapters** | `GamesLibrary/Adapters/Outbound/` | DTOs, mappers, repository, cache, network |
| **Composition root** | `AppContainer`, `AppCoordinator` | Wires dependencies; ViewModels receive inbound ports only |

Dependency flow: **Views → ViewModels → Use Cases → Repository Port → Network/Cache**

Local helper packages: `IOSConveniences`, `SwiftUIComponents`, `GamesLibraryUITestKit`, `GamesLibraryAccessibilityIdentifiers`.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/playbooks/](docs/playbooks/README.md) for the full playbook reference.

### Dependencies

- **[ASTK](https://github.com/illescasDaniel/astk)** (`AsyncSharedTestingKit`) — shared-process UI testing framework extracted from this app: launch once, apply Codable scenarios at runtime, drive screens with async page objects. See [UI tests](#ui-tests).
- **[OptimizedAsyncImage](https://github.com/illescasDaniel/OptimizedAsyncImage)** — used instead of SwiftUI `AsyncImage` primarily for **ImageIO downsampling via `targetSize`** (list/detail thumbnails). Native `AsyncImage` gained HTTP caching on iOS 27+, but it does not downsample; revisit only if the deployment target is iOS 27+ *and* downsampling is reimplemented or dropped.
- **[HTTIES](https://github.com/illescasDaniel/HTTIES)**, **[BetterLogger](https://github.com/illescasDaniel/BetterLogger)**, **[TTLCache](https://github.com/illescasDaniel/TTLCache)** — HTTP client, logging, and in-memory TTL cache.

### Spec-Driven Development (SDD)

Features are defined in `specs/<feature>/SPEC.md` before code changes. The repo is the source of truth; Jira/Linear track work.

**Phase Gate Protocol** (enforced for agents in [AGENTS.md](AGENTS.md)):

1. **Spec** — write/update `SPEC.md` with BDD acceptance criteria; get approval
2. **Architecture** — add ports and domain types in `GamesLibraryCore`; get approval
3. **Tests** — map BDD scenarios to Swift Testing tests
4. **Implementation** — adapters and UI until tests pass

Current specs: [games-list](specs/games-list/SPEC.md), [game-details](specs/game-details/SPEC.md)

### MCP tools (AI-assisted development)

This project configures MCP servers for agent workflows:

| Server | Config | Purpose |
|--------|--------|---------|
| **`ios-simulator`** | [`.cursor/mcp.json`](.cursor/mcp.json) | Explore live UI on a booted simulator (`get_ui_tree`, tap, type) before writing XCUITests |
| **`xcode-tools`** | `~/.cursor/mcp.json` (global) | Build, run tests, render SwiftUI previews from Xcode |

Enable both in **Cursor → Settings → MCP**. See [docs/playbooks/ios-simulator-mcp.md](docs/playbooks/ios-simulator-mcp.md) for setup and the SDD explore → interact → codify UI-test workflow.

## Features

- Game list with search, pull-to-refresh, and infinite scroll
- Game details screen
- English and Spanish (String Catalog)
- In-memory TTL cache (5 minutes)
- Shared-process UI tests via [ASTK](https://github.com/illescasDaniel/astk) (no live API)
- Swift 6, Swift Testing

## Development

The project requires an API key from https://rawg.io/apidocs (free tier).

Copy `Secrets.swift.sample` to `GamesLibrary/Configuration/Secrets.swift` and set your RAWG API key. Copy `Config.xcconfig.sample` to `Config.xcconfig` and set your Apple `DEVELOPMENT_TEAM`. Both local files are gitignored. The API key is a plain Swift string literal (not in `Info.plist`).

**Security:** That string is still **easily recoverable** from the app binary (`strings`, disassembly). Do **not** ship real production API keys in client apps — prefer a backend (BFF) that holds secrets and authenticates the client. This demo’s client key is intentional learning debt, not a pattern to copy.

### Previews

Previews use mock use-case ports — no live API key required.

### Running tests

```bash
# Core package tests
cd GamesLibraryCore && swift test

# App unit tests and UI tests: Xcode scheme GamesLibrary / GamesLibrary.xctestplan
```

UI tests are serial (`parallelizable: false`) because they share one app process.

### UI tests

UI tests use **[ASTK](https://github.com/illescasDaniel/astk)** (`AsyncSharedTestingKit`), a shared-process framework extracted from this app and published for reuse. It targets the two expensive parts of XCUITest: **cold launching per test** and **blocking sequential waits**.

**Shared-process launch** — the suite starts the app once (`UITESTING=1`) and applies each scenario at runtime via a Debug-only deep link (`gameslibrary-uitest://apply?config=…`). SwiftUI recreates the root with `.id(generation)` so ViewModels and `.task` loaders run fresh, without a process restart. Stubs are wired at the composition root through `UITestConfiguration`; no network, no API key, no dependency on RAWG uptime. Release builds do not register the test URL scheme.

**Async page objects** — pages live in `GamesLibraryUITests/Pages/` and import the `ASTKXCTest` product. Element accessors are `get async throws`: they wait via **`XCTWaiter`** (`XCTNSPredicateExpectation` + `fulfillment`) instead of blocking on sync `waitForExistence`. When several elements on the same screen appear together, tests wait in parallel:

```swift
async let rating = details.rating
async let year = details.year
async let playtime = details.playtime
_ = try await (rating, year, playtime)
```

On an iPhone 18 Pro simulator (8 UI tests, Sep 2026), switching from sync waits to async + `async let` cut total suite time from **70.3s → 60.4s (~14%)**; the metadata-chips test alone dropped **12.4s → 8.1s (~35%)** because five sequential waits became one concurrent wait. Combined with one launch for the whole suite, that removes both inter-test launch cost and in-test idle time.

See the [ASTK README](https://github.com/illescasDaniel/astk) for the reusable framework and [docs/playbooks/GamesLibrary-adaptations.md](docs/playbooks/GamesLibrary-adaptations.md) for POM layout, shared-process launch, and scenario config in this app.

Agent memory bank (per-branch project state): [memory/README.md](memory/README.md).
