import XCTest
import AccessibilityIdentifiers

enum AppLauncher {
	@MainActor
	static func launchGamesList(
		forceEmptyResults: Bool = false,
		forceDetailsFailure: Bool = false
	) -> GamesListPage {
		let app = XCUIApplication()
		app.terminate()
		app.launchArguments = ["-UITesting"]
		app.launchEnvironment = launchEnvironment(
			forceEmptyResults: forceEmptyResults,
			forceDetailsFailure: forceDetailsFailure
		)
		app.launch()
		return GamesListPage(app: app)
	}

	/// Launches the games list, taps the row at `index`, and returns the details page.
	@MainActor
	static func launchGameDetails(
		index: Int = 0,
		forceDetailsFailure: Bool = false
	) async throws -> GameDetailsPage {
		let list = launchGamesList(forceDetailsFailure: forceDetailsFailure)
		return try await list.tapGameRow(at: index)
	}

	private static func launchEnvironment(
		forceEmptyResults: Bool,
		forceDetailsFailure: Bool
	) -> [String: String] {
		var environment: [String: String] = [:]
		if forceEmptyResults {
			environment[UITestEnvironment.forceEmptyResultsKey] = "1"
		}
		if forceDetailsFailure {
			environment[UITestEnvironment.forceDetailsFailureKey] = "1"
		}
		return environment
	}
}
