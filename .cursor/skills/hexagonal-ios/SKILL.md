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
| Screen view | `GamesLibrary/Adapters/Inbound/UI/<Feature>/<Screen>View.swift` |
| Screen ViewModel | `GamesLibrary/Adapters/Inbound/UI/<Feature>/<Screen>ViewModel.swift` |
| Screen subviews | `GamesLibrary/Adapters/Inbound/UI/<Feature>/Subviews/` |
| Feature navigation view | `GamesLibrary/Adapters/Inbound/UI/<Feature>/` (e.g. `GamesNavigationView`; not in `Subviews/`) |
| Shared UI helpers | `GamesLibrary/Adapters/Inbound/UI/ConvenienceViews/`, `…/Models/` |
| App root shell | `GamesLibrary/Navigation/` (`AppRootView`) |
| Assets / String Catalog | `GamesLibrary/Resources/` (`Assets.xcassets`, `Localizable.xcstrings`) |
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

## SwiftUI section / row factoring

Follow `docs/playbooks/GamesLibrary-adaptations.md` → **SwiftUI view factoring** and Apple `swiftui-specialist/references/structure.md`:

- Named sections and list rows → separate `struct …: View` with **narrow inputs** (not `private var …: some View` on the parent for organization), in `Subviews/`.
- Screen views own `@State` ViewModels; section views do **not** get their own ViewModels and should not take the full ViewModel.
- Tiny constant fragments may stay as computed properties.

## Core import guard

`import SwiftUI` in Core compiles but is forbidden. Verify with:

```bash
rg '^import (SwiftUI|SwiftData|UIKit)' GamesLibraryCore/Sources
```
