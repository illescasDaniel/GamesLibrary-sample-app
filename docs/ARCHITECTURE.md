# GamesLibrary Architecture

Hexagonal Architecture (Ports & Adapters) with MVVM as the UI presentation pattern, and Spec-Driven Development for feature work.

## Modules

| Module | Role |
|--------|------|
| **GamesLibraryCore** (local Swift package) | Domain entities, inbound/outbound ports, use cases. Zero third-party dependencies. |
| **GamesLibrary** (app target) | Inbound adapters (SwiftUI), outbound adapters (HTTP, cache, DTOs), composition root. |

## Dependency flow

```
Views → ViewModels → Inbound Ports (Use Cases) → Outbound Ports (Repository)
                                                         ↓
                                              Network / Cache / DTOs
```

- `AppContainer` is the composition root: wires HTTP, cache, repository, use cases, and ViewModel factories.
- `AppCoordinator` owns navigation; views receive ViewModels via constructor injection.
- `#Preview` mocks inbound ports, not ViewModels.

## SDD

Feature specs live in `specs/`. See [AGENTS.md](../AGENTS.md) for the Phase Gate Protocol.

Agent session state (progress, focus, decisions) lives in [`memory/`](../memory/README.md).

## Reference playbooks

Vendored in [`docs/playbooks/`](playbooks/README.md). Start with [`GamesLibrary-adaptations.md`](playbooks/GamesLibrary-adaptations.md) for project-specific overrides, then the full playbooks as needed.
