# GamesLibrary

Simple iOS app that presents a list of games using the RAWG API.

Built with **Hexagonal Architecture**, **Spec-Driven Development (SDD)**, and **MVVM** as the UI presentation pattern.

## AI-ready

This repo is set up so humans and AI agents share the same source of truth:

| Piece | Where | Purpose |
|-------|-------|---------|
| Agent protocol | [AGENTS.md](AGENTS.md) | Phase gates for spec → ports → tests → implementation |
| Always-on rules | `.cursor/rules/` | Hexagonal boundaries, SDD, playbooks, **memory protocol** |
| Skills | `.cursor/skills/` | Project workflows (`sdd-feature`, `hexagonal-ios`, `playbooks`) plus Apple Xcode 27 skills (`swiftui-specialist`, …) |
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

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/playbooks/](docs/playbooks/README.md) for the full playbook reference.

### Dependencies

- **OptimizedAsyncImage** — used instead of SwiftUI `AsyncImage` primarily for **ImageIO downsampling via `targetSize`** (list/detail thumbnails). Native `AsyncImage` gained HTTP caching on iOS 27+, but it does not downsample; revisit only if the deployment target is iOS 27+ *and* downsampling is reimplemented or dropped.

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
- In-memory TTL cache (5 minutes)
- Swift 6, Swift Testing

## Development

The project requires an API key from https://rawg.io/apidocs (free tier).

Copy `Config.xcconfig.sample` to `Config.xcconfig` and set `API_KEY` plus your Apple `DEVELOPMENT_TEAM`. Build settings inject the key into a small C helper via `OTHER_CFLAGS` (not `Info.plist`), so it is not readable from the bundled plist. `Config.xcconfig` is gitignored.

**Security:** That C string is still **easily recoverable** from the app binary (`strings`, disassembly). Do **not** ship real production API keys in client apps — prefer a backend (BFF) that holds secrets and authenticates the client. This demo’s client key is intentional learning debt, not a pattern to copy.

### Previews

Previews use mock use-case ports — no live API key required.

### Running tests

```bash
# Core package tests
cd GamesLibraryCore && swift test

# App unit tests (via Xcode scheme GamesLibraryTests)
```

### UI tests

UI tests launch with `UITEST_CONFIG`, which wires stub inbound use cases at the composition root. No network, no API key, no dependency on RAWG uptime.

Agent memory bank (per-branch project state): [memory/README.md](memory/README.md).
