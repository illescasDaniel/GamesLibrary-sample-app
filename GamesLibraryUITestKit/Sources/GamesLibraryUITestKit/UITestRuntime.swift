import Foundation
import AccessibilityIdentifiers

@MainActor
public enum UITestRuntime {
	public static var scenarioHost: UITestScenarioHost?
	public static weak var navigationResetter: (any UITestNavigationResetting)?
	public static var onSessionApplied: ((Int) -> Void)?

	public static func handleOpenURL(_ url: URL) {
		guard let configuration = UITestApplyHandler.configuration(from: url) else { return }
		apply(configuration)
	}

	public static func applyPendingConfiguration() {
		guard let configuration = UITestApplyHandler.configurationFromPasteboard() else { return }
		apply(configuration)
	}

	private static func apply(_ configuration: UITestConfiguration) {
		guard let scenarioHost else { return }
		navigationResetter?.resetNavigation()
		scenarioHost.apply(configuration)
		onSessionApplied?(scenarioHost.sessionGeneration)
	}
}
