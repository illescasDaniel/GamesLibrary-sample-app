#if DEBUG
import SwiftUI

@main
struct DebugGamesLibraryApp: App {
	private let container: AppContainer
	@State private var coordinator: AppCoordinator

	init() {
		let container: AppContainer
		if Self.isRunningUITests {
			container = AppContainer(gamesRepository: StubGamesRepository())
		} else {
			container = AppContainer()
			container.configureSharedURLCache()
		}
		self.container = container
		self._coordinator = State(initialValue: AppCoordinator(container: container))
	}

	var body: some Scene {
		WindowGroup {
			if Self.isRunningUnitTests {
				EmptyView()
			} else {
				RootView(coordinator: coordinator, container: container)
			}
		}
	}

	private static var isRunningUnitTests: Bool {
		ProcessInfo.processInfo.environment["IS_TESTING"] == "1"
	}

	private static var isRunningUITests: Bool {
		ProcessInfo.processInfo.arguments.contains("-UITesting")
	}
}
#endif
