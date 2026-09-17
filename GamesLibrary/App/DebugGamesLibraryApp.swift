#if DEBUG
import SwiftUI

@main
struct DebugGamesLibraryApp: App {
	private let container: any AppContaining
	@State private var coordinator: AppCoordinator

	init() {
		let container: any AppContaining
		if let overrides = UITestSupport.makeOverrides() {
			container = DebugAppContainer(overrides: overrides)
		} else {
			let debugContainer = DebugAppContainer(overrides: .debugDefaults())
			debugContainer.configureSharedURLCache()
			container = debugContainer
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
}
#endif
