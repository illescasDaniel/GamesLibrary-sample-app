#if DEBUG
import SwiftUI
import AccessibilityIdentifiers
import ASTK
import ASTKApp
import GamesLibraryUITestKit

/// DEBUG composition root + session shell for shared-process UI tests.
struct UITestAppContent: View {
	@State private var coordinator: AppCoordinator
	@State private var scenarioHost: UITestScenarioHost
	@State private var uiTestSessionGeneration = 0
	@State private var sessionCoordinator: UITestSessionCoordinator<UITestConfiguration>

	init() {
		let host = UITestScenarioHost()
		if let initial = UITestSupport.initialConfiguration() {
			host.apply(initial)
		} else {
			host.apply(.default)
		}
		let debugContainer = DebugAppContainer(overrides: .init(
			searchGamesUseCase: host.searchGamesUseCase,
			getGameDetailsUseCase: host.getGameDetailsUseCase,
			urlCache: URLCache(memoryCapacity: 0, diskCapacity: 0)
		))
		self._scenarioHost = State(initialValue: host)
		self._coordinator = State(initialValue: AppCoordinator(container: debugContainer))
		self._sessionCoordinator = State(
			initialValue: UITestSessionCoordinator(settings: UITestSupport.sessionSettings)
		)
	}

	var body: some View {
		@Bindable var coordinator = coordinator
		@Bindable var scenarioHost = scenarioHost

		ZStack(alignment: .topLeading) {
			AppRootView(coordinator: coordinator)
				.id(uiTestSessionGeneration)
			if uiTestSessionGeneration > 0 {
				Color.clear
					.frame(width: 1, height: 1)
					.accessibilityElement()
					.accessibilityIdentifier(
						UITestReadyMarker.identifier(sessionGeneration: uiTestSessionGeneration)
					)
					.allowsHitTesting(false)
			}
		}
		.onAppear {
			wireSessionRuntime(scenarioHost: scenarioHost, coordinator: coordinator)
		}
		.onChange(of: scenarioHost.sessionGeneration) { _, generation in
			uiTestSessionGeneration = generation
		}
		.onOpenURL { sessionCoordinator.handleOpenURL($0) }
	}

	private func wireSessionRuntime(
		scenarioHost: UITestScenarioHost,
		coordinator: AppCoordinator
	) {
		sessionCoordinator.scenarioHost = scenarioHost
		sessionCoordinator.navigationResetter = coordinator
		uiTestSessionGeneration = scenarioHost.sessionGeneration
	}
}
#endif
