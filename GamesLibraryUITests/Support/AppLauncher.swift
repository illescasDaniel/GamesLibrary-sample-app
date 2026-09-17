import XCTest
import AccessibilityIdentifiers

enum AppLauncher {
	@MainActor
	static func launchGamesList(
		configuration: UITestConfiguration = .default
	) -> GamesListPage {
		let app = XCUIApplication()
		app.terminate()
		app.launchEnvironment = [
			UITestEnvironment.configKey: configuration.encodeToLaunchEnvironmentValue(),
		]
		app.launch()
		return GamesListPage(app: app)
	}

	/// Launches the games list, taps the row at `index`, and returns the details page.
	@MainActor
	static func launchGameDetails(
		index: Int = 0,
		configuration: UITestConfiguration = .default
	) async throws -> GameDetailsPage {
		let list = launchGamesList(configuration: configuration)
		return try await list.tapGameRow(at: index)
	}
}
