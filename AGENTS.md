# GamesLibrary — Agent Instructions

This repository uses **Spec-Driven Development (SDD)** and **Hexagonal Architecture**. Follow the Phase Gate Protocol for every feature or architectural change.

## Memory bank

Per-branch project state lives in `memory/` (git-tracked). Always-on rule: `.cursor/rules/agent-memory.mdc`.

1. **Session start:** read `memory/activeContext.md`, then `memory/progress.md`.
2. **During work:** update those files only on the triggers in the rule; append significant choices to `memory/decisions.md` (newest first, never rewrite history).
3. **Hand-off:** before finishing a session with progress, leave `activeContext.md` as the next prompt's starting point.

How the files work and how to reset them on a new branch: [memory/README.md](memory/README.md).

## Phase Gate Protocol

1. **Phase 1 — Spec:** Read or write the relevant `specs/<feature>/SPEC.md`. Stop and ask for human approval before proceeding.
2. **Phase 2 — Architecture:** Write or update ports (protocols) and domain types in `GamesLibraryCore`. Stop and ask for approval.
3. **Phase 3 — Tests:** Write unit tests from the BDD acceptance criteria. Tests must compile; implementations may be stubs.
4. **Phase 4 — Implementation:** Write adapters, ViewModels, and views until tests pass.

If Phase 4 reveals a flaw in the spec, **rewrite the spec** (Phase 1), then update ports and tests. Do not patch around a bad spec.

## Code style

- Use **tabs** for indentation in Swift and all project source files — not spaces.

## Architecture rules

- **GamesLibraryCore** (local Swift package): pure domain entities, inbound/outbound ports, use cases. No `SwiftUI`, `HTTIES`, `SwiftData`, or DTOs.
- **GamesLibrary** (app target): inbound adapters (SwiftUI + ViewModels), outbound adapters (repository, DTOs, mappers, cache, network), composition root (`AppContainer`), navigation (`AppCoordinator`).
- ViewModels depend on **inbound ports** only, never repositories or HTTP clients.
- `#Preview` mocks the **port** (use case or repository), never the ViewModel.
- DTO-to-entity mapping lives next to the DTO in the outbound adapter layer.

## Reference playbooks

Senior iOS engineering playbooks are vendored in `docs/playbooks/`. Read `docs/playbooks/GamesLibrary-adaptations.md` first — it records how this repo differs from the generic examples.

| Doc | Purpose |
|-----|---------|
| `docs/playbooks/hexagonal-architecture.md` | Ports, adapters, composition root |
| `docs/playbooks/spec-driven-development.md` | SDD philosophy and phase gates |
| `docs/playbooks/senior-ios-developer.md` | Security, coordinator DI, previews |

## MCP tools

| Server | Config | Use for |
|--------|--------|---------|
| `ios-simulator` | `.cursor/mcp.json` | Explore UI on simulator before writing XCUITests |
| `xcode-tools` | `~/.cursor/mcp.json` (global) | Build, run tests, SwiftUI previews |

See `docs/playbooks/ios-simulator-mcp.md`. Enable servers in Cursor Settings → MCP.

## Skills

Project workflows (this repo):

- `.cursor/skills/sdd-feature/` — SDD workflow for new/changed flows
- `.cursor/skills/hexagonal-ios/` — file placement and port naming
- `.cursor/skills/playbooks/` — when to read full playbooks vs project adaptations
- `.cursor/skills/apply-worktree/` — merge an isolated agent worktree into the main checkout (`/apply-worktree`)
- `.cursor/skills/delete-worktree/` — remove a finished agent worktree (`/delete-worktree`)

Apple Xcode 27 agent skills (exported into `.cursor/skills/`):

| Skill | Use when |
|-------|----------|
| `swiftui-specialist` | Writing, reviewing, or refactoring SwiftUI |
| `swiftui-whats-new-27` | SDK 27 SwiftUI APIs, `@State` macro, deprecations |
| `modernize-tests` | Swift Testing patterns or XCTest → Swift Testing (UI tests stay XCTest) |
| `app-intents-specialist` | App Intents best practices |
| `app-intents-whats-new-27` | App Intents APIs new in iOS 26/27 |
| `building-document-based-swiftui-applications` | Document-based SwiftUI apps |
| `uikit-app-modernization` | UIKit multi-window / scene lifecycle |
| `adopt-c-bounds-safety` | C `-fbounds-safety` |
| `audit-xcode-security-settings` | Hardening Xcode build settings |
| `device-interaction` | Verify UI on simulator/device via `xcode-tools` MCP |

**Conflict rule:** hexagonal + SDD skills and `GamesLibrary-adaptations.md` win over Apple’s generic architecture advice (ViewModels still depend on inbound ports; `#Preview` still mocks the port).

Refresh after an Xcode update (do **not** `--replace-existing` into `.cursor/skills/` — that would wipe project skills):

```bash
xcrun agent skills export --output-dir /tmp/xcode-skills --replace-existing
cp -R /tmp/xcode-skills/* .cursor/skills/
```

Always-on rules include `agent-memory.mdc` (session memory), `sdd.mdc`, `hexagonal-ios.mdc`, and `playbooks.mdc`.

## Source of truth

`specs/` holds feature specifications. `memory/` holds per-branch agent state. Jira/Linear track work; the repo tracks truth.
