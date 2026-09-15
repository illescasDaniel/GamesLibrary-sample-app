import Observation
import SwiftUI

@Observable
final class AppCoordinator {
    var path = NavigationPath()
    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func push(_ route: Route) {
        path.append(route)
    }

    @ViewBuilder
    func build(_ route: Route) -> some View {
        switch route {
        case .details(let summary):
            GameDetailsView(
                viewModel: container.makeGameDetailsViewModel(),
                summary: summary
            )
        }
    }
}
