---
name: hexagonal-ios
description: Hexagonal architecture file placement and port naming for GamesLibrary. Use when adding use cases, repositories, mappers, ViewModels, or refactoring layers.
---

# Hexagonal iOS — GamesLibrary

## File placement

| Element | Location |
|---------|----------|
| Domain entity | `GamesLibraryCore/.../Domain/Entities/` |
| Inbound port | `GamesLibraryCore/.../Application/Ports/Inbound/` |
| Outbound port | `GamesLibraryCore/.../Application/Ports/Outbound/` |
| Use case | `GamesLibraryCore/.../Application/UseCases/` |
| ViewModel | `GamesLibrary/Adapters/Inbound/UI/` |
| View | `GamesLibrary/Adapters/Inbound/UI/` |
| DTO (`Decodable`) | `GamesLibrary/Adapters/Outbound/DTOs/` |
| Mapper | `GamesLibrary/Adapters/Outbound/Mappers/` |
| Repository impl | `GamesLibrary/Adapters/Outbound/` |
| AppContainer | `GamesLibrary/DependencyInjection/` |
| AppCoordinator | `GamesLibrary/Navigation/` |

## Port naming

- Inbound: `SearchGamesUseCasePort`, `GetGameDetailsUseCasePort`
- Outbound: `GamesRepositoryPort`

## Previews

Mock the inbound port, inject into the real ViewModel:

```swift
#Preview {
	GameListView(viewModel: GamesListViewModel(
		searchGames: MockSearchGamesUseCase(result: .success([...])),
		logger: BetterLogger(name: "Preview")
	))
}
```

## Related Apple skills

When writing or reviewing SwiftUI, also apply `swiftui-specialist` (and `swiftui-whats-new-27` for SDK 27 APIs). This skill still wins on file placement, ports, and previews.

## Core import guard

`import SwiftUI` in Core compiles but is forbidden. Verify with:

```bash
rg '^import (SwiftUI|SwiftData|UIKit)' GamesLibraryCore/Sources
```
