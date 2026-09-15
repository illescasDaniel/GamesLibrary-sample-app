#if !DEBUG
import SwiftUI

@main
struct GamesLibraryApp: App {
	private let container: AppContainer
	@State private var coordinator: AppCoordinator

	init() {
		let container = AppContainer()
		container.configureSharedURLCache()
		self.container = container
		self._coordinator = State(initialValue: AppCoordinator(container: container))
	}

	var body: some Scene {
		WindowGroup {
			RootView(coordinator: coordinator, container: container)
		}
	}
}
#endif
