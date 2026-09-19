import Observation
import SwiftUI

@Observable
final class AppCoordinator {
	var path = NavigationPath()
	private let container: any AppContaining

	init(container: any AppContaining) {
		self.container = container
	}

	func push(_ route: Route) {
		path.append(route)
	}

	func resetNavigation() {
		path = NavigationPath()
	}

	@ViewBuilder
	func build(_ route: Route) -> some View {
		switch route {
		case .gamesList:
			GameListView(viewModel: container.makeGamesListViewModel())
		case .details(let summary):
			GameDetailsView(
				viewModel: container.makeGameDetailsViewModel(),
				summary: summary
			)
		}
	}
}
