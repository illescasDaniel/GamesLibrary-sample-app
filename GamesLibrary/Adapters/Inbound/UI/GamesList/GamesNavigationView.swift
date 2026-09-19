import SwiftUI

struct GamesNavigationView: View {
	@Environment(AppCoordinator.self) private var coordinator

	var body: some View {
		@Bindable var coordinator = coordinator
		NavigationStack(path: $coordinator.path) {
			coordinator.build(.gamesList)
				.navigationDestination(for: Route.self) { route in
					coordinator.build(route)
				}
		}
	}
}

#if DEBUG
import GamesLibraryCore
import GamesLibraryUITestKit

#Preview {
	let container = DebugAppContainer(overrides: .init(
		searchGamesUseCase: StubSearchGamesUseCase.constant([
			GameSummary(id: GameID(1), name: "Preview Game", rating: 4.5, released: "2024-01-01"),
		])
	))
	GamesNavigationView()
		.environment(AppCoordinator(container: container))
}
#endif
