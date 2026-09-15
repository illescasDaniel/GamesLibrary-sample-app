# Senior iOS Playbooks (Reference)

Canonical engineering playbooks vendored into this repo so agents, CI, and collaborators do not depend on machine-local paths.

## How agents should use these docs

| Layer | Location | When to read |
|-------|----------|--------------|
| **Session memory** | `memory/activeContext.md`, `memory/progress.md` | Start of every session (always-on `agent-memory.mdc`) |
| **Enforcement** | `.cursor/rules/*.mdc` | Always applied — hard constraints |
| **Workflow** | `AGENTS.md` | Start of every feature or architectural change |
| **Project map** | `docs/ARCHITECTURE.md` | How this repo maps playbooks to code |
| **This repo's overrides** | `GamesLibrary-adaptations.md` | Before applying generic playbook advice |
| **Full playbooks** | Files below | Deep context on architecture, SDD, or senior practices |

**Order:** read memory → `AGENTS.md` → `GamesLibrary-adaptations.md` → the relevant playbook chapter → feature `specs/<feature>/SPEC.md`.

## Playbooks

| File | Topic |
|------|--------|
| [hexagonal-architecture.md](hexagonal-architecture.md) | Ports & adapters, file tree, DI composition root, golden rules |
| [spec-driven-development.md](spec-driven-development.md) | SDD philosophy, `SPEC.md` anatomy, phase gates, test boundaries |
| [senior-ios-developer.md](senior-ios-developer.md) | Security, BFF, analytics, MVVM vs hexagonal, coordinator DI |

## Upstream

Copied from the author's reference repo (`SDD_Hexagonal-Architecture_MVVM/docs`). When playbooks change upstream, re-copy and note the update in git history.
