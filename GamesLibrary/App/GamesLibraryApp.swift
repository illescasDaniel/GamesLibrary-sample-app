#if !DEBUG
import SwiftUI

@main
struct GamesLibraryApp: App {
	@State private var coordinator: AppCoordinator

	init() {
		let container = AppContainer()
		container.configureSharedURLCache()
		self._coordinator = State(initialValue: AppCoordinator(container: container))
	}

	var body: some Scene {
		WindowGroup {
			AppRootView(coordinator: coordinator)
		}
	}
}
#endif
