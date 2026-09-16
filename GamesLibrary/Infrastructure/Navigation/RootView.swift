import SwiftUI

struct RootView: View {
	@Bindable var coordinator: AppCoordinator
	let container: AppContainer

	var body: some View {
		NavigationStack(path: $coordinator.path) {
			GameListView(viewModel: container.makeGamesListViewModel())
				.navigationDestination(for: Route.self) { route in
					coordinator.build(route)
				}
		}
		.environment(coordinator)
	}
}
