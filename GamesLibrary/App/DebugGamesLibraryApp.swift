#if DEBUG
import SwiftUI
import AccessibilityIdentifiers
import GamesLibraryUITestKit

@main
struct DebugGamesLibraryApp: App {
	@State private var coordinator: AppCoordinator?
	@State private var scenarioHost: UITestScenarioHost?

	init() {
		if UnitTestProcessInfo.isRunningUnitTests {
			self._coordinator = State(initialValue: nil)
			self._scenarioHost = State(initialValue: nil)
			return
		}

		let coordinator: AppCoordinator
		var scenarioHost: UITestScenarioHost?

		if UITestSupport.isSharedProcessUITesting {
			let host = UITestScenarioHost()
			if let initial = UITestSupport.initialConfiguration() {
				host.apply(initial)
			} else {
				host.apply(.default)
			}
			let debugContainer = DebugAppContainer(scenarioHost: host)
			coordinator = AppCoordinator(container: debugContainer)
			scenarioHost = host
		} else {
			let debugContainer = DebugAppContainer()
			debugContainer.configureSharedURLCache()
			coordinator = AppCoordinator(container: debugContainer)
		}

		self._coordinator = State(initialValue: coordinator)
		self._scenarioHost = State(initialValue: scenarioHost)
	}

	var body: some Scene {
		WindowGroup {
			if let scenarioHost, let coordinator {
				UITestAppContent(
					coordinator: coordinator,
					scenarioHost: scenarioHost
				)
			} else if let coordinator {
				AppRootView(coordinator: coordinator)
			} else {
				EmptyView()
			}
		}
	}

}
#endif
