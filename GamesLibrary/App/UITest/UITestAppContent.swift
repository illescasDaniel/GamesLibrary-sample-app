#if DEBUG
import SwiftUI
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
				UITestHarnessView(sessionGeneration: uiTestSessionGeneration)
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
		UITestRuntime.onSessionApplied = { uiTestSessionGeneration = $0 }
		uiTestSessionGeneration = scenarioHost.sessionGeneration
	}
}
#endif
