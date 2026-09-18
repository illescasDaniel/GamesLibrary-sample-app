#if DEBUG
import SwiftUI
import AccessibilityIdentifiers
import GamesLibraryUITestKit

@main
struct DebugGamesLibraryApp: App {
	private let container: any AppContaining
	@State private var coordinator: AppCoordinator
	@State private var scenarioHost: UITestScenarioHost?
	@State private var uiTestSessionGeneration = 0

	init() {
		let container: any AppContaining
		let coordinator: AppCoordinator
		var scenarioHost: UITestScenarioHost?
		var initialSessionGeneration = 0

		if UITestSupport.isSharedProcessUITesting {
			let host = UITestScenarioHost()
			if let initial = UITestSupport.initialConfiguration() {
				host.apply(initial)
			} else {
				host.apply(.default)
			}
			let debugContainer = DebugAppContainer(scenarioHost: host)
			container = debugContainer
			coordinator = AppCoordinator(container: debugContainer)
			scenarioHost = host
			initialSessionGeneration = host.sessionGeneration
		} else if let overrides = DebugAppContainer.Overrides.uitestFromLaunchEnvironment() {
			container = DebugAppContainer(overrides: overrides)
			coordinator = AppCoordinator(container: container)
		} else {
			let debugContainer = DebugAppContainer()
			debugContainer.configureSharedURLCache()
			container = debugContainer
			coordinator = AppCoordinator(container: debugContainer)
		}

		self.container = container
		self._coordinator = State(initialValue: coordinator)
		self._scenarioHost = State(initialValue: scenarioHost)
		self._uiTestSessionGeneration = State(initialValue: initialSessionGeneration)
	}

	var body: some Scene {
		WindowGroup {
			if Self.isRunningUnitTests {
				EmptyView()
			} else if let scenarioHost {
				UITestAppContent(
					coordinator: coordinator,
					container: container,
					scenarioHost: scenarioHost,
					uiTestSessionGeneration: $uiTestSessionGeneration
				)
				.onOpenURL(perform: UITestRuntime.handleOpenURL)
			} else {
				RootView(
					coordinator: coordinator,
					container: container
				)
			}
		}
	}

	private static var isRunningUnitTests: Bool {
		ProcessInfo.processInfo.environment["IS_TESTING"] == "1"
	}
}
#endif
