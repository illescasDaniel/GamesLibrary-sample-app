# iOS Simulator MCP (SDD UI workflow)

The [SDD playbook](spec-driven-development.md) (Chapter 5) describes using an **iOS Simulator MCP** so agents can explore UI flows before writing XCUITests:

1. **Explore** — read the accessibility tree (`get_ui_tree`)
2. **Interact** — tap, type, swipe to walk the flow
3. **Codify** — write XCUITest code using real identifiers, not guesses

## Configured for this repo

Project MCP config: [`.cursor/mcp.json`](../../.cursor/mcp.json)

| Server | Package | Purpose |
|--------|---------|---------|
| `ios-simulator` | [`ios-mcp-server`](https://github.com/martingeidobler/ios-mcp-server) | UI tree, tap/type/swipe, screenshots, launch app |
| `xcode-tools` (global) | `mcpbridge-wrapper` via `~/.cursor/mcp.json` | Build, run tests, SwiftUI previews |

These complement each other: **xcode-tools** builds and runs tests; **ios-simulator** explores live UI on a booted simulator.

## Prerequisites

- macOS + Xcode command line tools
- Node.js 18+
- A **booted** iOS Simulator
- Enable `ios-simulator` in **Cursor → Settings → MCP** (toggle on if disabled)

First run compiles native helper binaries (`simtouch`, `simtree`); allow a minute.

## GamesLibrary defaults

| Setting | Value |
|---------|-------|
| Bundle ID | `com.illescasdaniel.GamesLibrary` |
| UI-test launch env | `UITEST_CONFIG` (stub use cases, no live API) |

Example agent flow for a new UI test:

1. `launch_app` with bundle ID (or build/run via xcode-tools first)
2. `get_ui_tree` — find accessibility identifiers and labels
3. `tap_element` / `type_text` — walk the scenario from `specs/<feature>/SPEC.md`
4. Write `GamesLibraryUITests` using verified identifiers

## When not to use

- Unit tests and ViewModel tests — use Swift Testing + mocks (no simulator MCP)
- CI — run `xcodebuild test`; MCP is for local agent-assisted exploration
