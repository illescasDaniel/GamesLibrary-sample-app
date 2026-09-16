# Active Context

_Last updated: 2026-09-16_

## Branch

<<<<<<< HEAD
- `develop` — current, pushed

## Current focus

Hexagonal/SDD feature work on `develop`.

## Just changed

- Committed + pushed: screen `@State` ViewModel ownership, list `.task` load, deleted empty `LaunchTests`
- All 37 tests passing (33 unit + 4 UI)

## Next steps

1. Continue hexagonal/SDD feature work on `develop`.
2. Keep `memory/` updated at session milestones per `.cursor/rules/agent-memory.mdc`.
=======
- `develop` — current

## Current focus

Agent worktree lifecycle skills added for isolated Cursor checkouts.

## Just changed

- `.cursor/skills/apply-worktree/` — commit → merge → iOS quality gate (`swift test` + xcode-tools `RunAllTests`)
- `.cursor/skills/delete-worktree/` — unregister worktree + optional `cursor/…` branch cleanup
- `AGENTS.md` — lists both skills under project workflows

## Next steps

1. Continue hexagonal/SDD work on `develop`.
2. Commit when Daniel asks (includes new skills + memory update).
>>>>>>> cursor/a37b7f1d
