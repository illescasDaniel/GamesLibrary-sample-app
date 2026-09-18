import Foundation
import AccessibilityIdentifiers

@MainActor
public enum UITestRuntime {
	public static var scenarioHost: UITestScenarioHost?
	public static weak var navigationResetter: (any UITestNavigationResetting)?

	public static func handleOpenURL(_ url: URL) {
		guard let configuration = UITestApplyHandler.configuration(from: url) else { return }
		guard let scenarioHost else { return }
		navigationResetter?.resetNavigation()
		scenarioHost.apply(configuration)
	}
}
