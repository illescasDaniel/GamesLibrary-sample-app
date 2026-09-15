---
name: playbooks
description: Read vendored senior iOS playbooks for GamesLibrary. Use when making architectural decisions, resolving layer-boundary questions, or when generic Swift/iOS advice conflicts with this project's hexagonal + SDD setup.
---

# Playbooks Reference Skill

## When to use

- Unsure where a type or mapper belongs (Core vs Infrastructure)
- Choosing between constructor injection, coordinator, or environment
- Writing or reviewing a feature spec, ports, or test boundaries
- Security or networking questions (BFF, pinning, API keys)

## Read order

1. `memory/activeContext.md` then `memory/progress.md` (always-on `agent-memory.mdc`)
2. `AGENTS.md`
3. `docs/playbooks/GamesLibrary-adaptations.md`
4. One or more playbooks from `docs/playbooks/`:
   - `hexagonal-architecture.md`
   - `spec-driven-development.md`
   - `senior-ios-developer.md`
5. Feature spec: `specs/<feature>/SPEC.md`

## Related Apple skills

For SwiftUI implementation details, also apply `swiftui-specialist` (and `swiftui-whats-new-27` for SDK 27 APIs). For unit-test style, `modernize-tests`. Project hexagonal/SDD rules still win on layering and phase gates.

## Do not

- Follow playbook file-tree examples literally — use `hexagonal-ios` skill for this repo's paths
- Add BFF, SSL pinning, or App Attest without an approved spec
- Put full playbook text into Cursor rules (rules stay short; playbooks stay in `docs/playbooks/`)
