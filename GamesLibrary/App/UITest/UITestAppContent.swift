#if DEBUG
import SwiftUI
import AccessibilityIdentifiers
import GamesLibraryUITestKit

/// DEBUG shell around production `RootView` for shared-process UI tests.
struct UITestAppContent: View {
	@Bindable var coordinator: AppCoordinator
	let container: any AppContaining
	@Bindable var scenarioHost: UITestScenarioHost
	@Binding var uiTestSessionGeneration: Int

	var body: some View {
		ZStack(alignment: .topLeading) {
			RootView(coordinator: coordinator, container: container)
				.id(uiTestSessionGeneration)
			if uiTestSessionGeneration > 0 {
				Color.clear
					.frame(width: 1, height: 1)
					.accessibilityElement()
					.accessibilityIdentifier(
						AccessibilityIdentifier.UITest.ready(sessionGeneration: uiTestSessionGeneration)
					)
					.allowsHitTesting(false)
			}
		}
		.onAppear {
			wireUITestRuntime()
		}
		.onChange(of: scenarioHost.sessionGeneration) { _, generation in
			uiTestSessionGeneration = generation
		}
	}

	private func wireUITestRuntime() {
		UITestRuntime.scenarioHost = scenarioHost
		UITestRuntime.navigationResetter = coordinator
		uiTestSessionGeneration = scenarioHost.sessionGeneration
	}
}
#endif
