#if !DEBUG
import SwiftUI

@main
struct GamesLibraryApp: App {
	var body: some Scene {
		WindowGroup {
			AppContent()
		}
	}
}

private struct AppContent: View {
	@State private var coordinator: AppCoordinator

	init() {
		let container = AppContainer()
		container.configureSharedURLCache()
		self._coordinator = State(initialValue: AppCoordinator(container: container))
	}

	var body: some View {
		AppRootView(coordinator: coordinator)
	}
}
#endif
