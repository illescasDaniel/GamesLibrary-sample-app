# Active Context

_Last updated: 2026-09-16_

## Branch

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
