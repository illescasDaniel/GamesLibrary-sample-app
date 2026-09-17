import XCTest
import AccessibilityIdentifiers

enum AppLauncher {
	@MainActor
	static func launchGamesList(forceEmptyResults: Bool = false) -> GamesListPage {
		let app = XCUIApplication()
		app.terminate()
		app.launchArguments = ["-UITesting"]
		app.launchEnvironment = forceEmptyResults
			? [UITestEnvironment.forceEmptyResultsKey: "1"]
			: [:]
		app.launch()
		return GamesListPage(app: app)
	}
}
