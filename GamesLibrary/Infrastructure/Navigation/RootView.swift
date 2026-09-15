import SwiftUI

struct RootView: View {
	@Bindable var coordinator: AppCoordinator
	let container: AppContainer
	@State private var gamesListViewModel: GamesListViewModel

	init(coordinator: AppCoordinator, container: AppContainer) {
		self.coordinator = coordinator
		self.container = container
		_gamesListViewModel = State(initialValue: container.makeGamesListViewModel())
	}

	var body: some View {
		NavigationStack(path: $coordinator.path) {
			GameListView(viewModel: gamesListViewModel)
				.navigationDestination(for: Route.self) { route in
					coordinator.build(route)
				}
		}
		.environment(coordinator)
	}
}
