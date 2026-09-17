#if DEBUG
import Foundation
import AccessibilityIdentifiers

enum UITestSupport {
	static var shouldForceEmptyResults: Bool {
		ProcessInfo.processInfo.environment[UITestEnvironment.forceEmptyResultsKey] == "1"
	}
}
#endif
