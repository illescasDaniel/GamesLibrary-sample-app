---
name: sdd-feature
description: Run Spec-Driven Development for GamesLibrary features. Use when adding or changing user-facing flows, writing SPEC.md, or implementing features from acceptance criteria.
---

# SDD Feature Workflow

## Phase 1 — Spec

Create or update `specs/<feature>/SPEC.md` with:

- Metadata & dependencies
- Triggers & routing
- Visual & UI rules
- Acceptance criteria (Given/When/Then)
- Out of scope (anti-goals)

**Stop for approval.**

## Phase 2 — Architecture

Add or update in `GamesLibraryCore`:

- Domain entities affected
- Inbound port (`*UseCasePort`)
- Outbound port if needed (`*RepositoryPort`)

**Stop for approval.**

## Phase 3 — Tests

Map each BDD scenario to a `@Test` in Swift Testing:

```swift
@Test
func givenUserOnListWhenSearchSucceedsThenGamesDisplayed() async { ... }
```

Tests target ViewModels and use cases — not SwiftUI views. Follow `modernize-tests` for Swift Testing style; UI tests stay XCTest.

## Phase 4 — Implementation

Implement adapters and UI until tests pass. For SwiftUI, apply `swiftui-specialist` (and `swiftui-whats-new-27` for SDK 27 APIs). Update `AGENTS.md` or specs only if behavior changed intentionally. Update `memory/` at milestones (see `.cursor/rules/agent-memory.mdc`).

### UI tests + Simulator MCP

When adding or fixing XCUITests, use the **ios-simulator** MCP (see `docs/playbooks/ios-simulator-mcp.md`):

1. Explore the flow with `get_ui_tree` and interactions on a booted simulator
2. Only then write XCUITest code with verified accessibility identifiers
3. Run tests via **xcode-tools** (`RunSomeTests`) or `xcodebuild test`

## Spec template

See existing specs: `specs/games-list/SPEC.md`, `specs/game-details/SPEC.md`.
