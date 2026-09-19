#if DEBUG
import SwiftUI
import GamesLibraryUITestKit

@main
struct DebugGamesLibraryApp: App {
	var body: some Scene {
		WindowGroup {
			if UITestSupport.isSharedProcessUITesting {
				UITestAppContent()
			} else if UnitTestProcessInfo.isRunningUnitTests {
				EmptyView()
			} else {
				DebugAppContent()
			}
		}
	}
}

private struct DebugAppContent: View {
	@State private var coordinator: AppCoordinator

	init() {
		let debugContainer = DebugAppContainer()
		debugContainer.configureSharedURLCache()
		self._coordinator = State(initialValue: AppCoordinator(container: debugContainer))
	}

	var body: some View {
		AppRootView(coordinator: coordinator)
	}
}
#endif
