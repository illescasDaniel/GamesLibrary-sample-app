# Active Context

_Last updated: 2026-09-15_

## Branch

- `develop` — current (hexagonal + SDD refactor uncommitted)

## Current focus

Re-indenting project source with tabs (per `AGENTS.md`); hexagonal/SDD refactor committed.

## Just changed

- DTOs: `nonisolated Decodable, Sendable` (HTTIES decodes in `@concurrent` context)
- `String.strippingHTML()`: `nonisolated` (Swift Testing calls from nonisolated context)
- App + test plan build and test clean on iPhone 17 / iOS 27

## Next steps

1. Continue hexagonal/SDD work on `develop` (commit when Daniel asks).
2. Keep `memory/` updated at session milestones per `.cursor/rules/agent-memory.mdc`.
