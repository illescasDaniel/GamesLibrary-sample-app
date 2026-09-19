#if DEBUG
import SwiftUI
import AccessibilityIdentifiers
import ASTK
import ASTKApp
import GamesLibraryUITestKit

/// DEBUG shell around production `AppRootView` for shared-process UI tests.
struct UITestAppContent: View {
	@Bindable var coordinator: AppCoordinator
	@Bindable var scenarioHost: UITestScenarioHost
	@Binding var uiTestSessionGeneration: Int
	@State private var sessionCoordinator: UITestSessionCoordinator<UITestConfiguration>

	init(
		coordinator: AppCoordinator,
		scenarioHost: UITestScenarioHost,
		uiTestSessionGeneration: Binding<Int>
	) {
		self._coordinator = Bindable(coordinator)
		self._scenarioHost = Bindable(scenarioHost)
		self._uiTestSessionGeneration = uiTestSessionGeneration
		self._sessionCoordinator = State(
			initialValue: UITestSessionCoordinator(settings: UITestSupport.sessionSettings)
		)
	}

	var body: some View {
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
			wireSessionRuntime()
		}
		.onChange(of: scenarioHost.sessionGeneration) { _, generation in
			uiTestSessionGeneration = generation
		}
		.onOpenURL { sessionCoordinator.handleOpenURL($0) }
	}

	private func wireSessionRuntime() {
		sessionCoordinator.scenarioHost = scenarioHost
		sessionCoordinator.navigationResetter = coordinator
		uiTestSessionGeneration = scenarioHost.sessionGeneration
	}
}
#endif
