import XCTest
import AccessibilityIdentifiers
import XCUITestPOM

@MainActor
enum AppLauncher {
	private static var app: XCUIApplication?
	private static var sessionGeneration = 0

	/// Launches the app once under shared-process UI testing (`UITESTING=1`).
	static func ensureLaunched() throws {
		if let app, app.state == .runningForeground {
			return
		}
		let application = XCUIApplication()
		application.terminate()
		application.launchEnvironment = [
			UITestEnvironment.testingKey: "1",
		]
		application.launch()
		app = application
		sessionGeneration = 1
		try application.waitForUITestReady(sessionGeneration: sessionGeneration)
	}

	/// Applies a scenario without relaunching: pop to root, open DEBUG deep link with URL-encoded config, wait for ready marker.
	@discardableResult
	static func apply(
		configuration: UITestConfiguration = .default
	) async throws -> GamesListPage {
		try ensureLaunched()
		guard let app else {
			preconditionFailure("Shared-process UI test app was not launched")
		}
		sessionGeneration += 1
		let generation = sessionGeneration
		popToRoot(in: app)
		let url = configuration.makeApplyDeepLinkURL()
		app.activate()
		XCUIDevice.shared.system.open(url)
		try await app.waitForUITestReadyAsync(sessionGeneration: generation)
		return GamesListPage(app: app)
	}

	/// Applies a scenario, taps the row at `index`, and returns the details page.
	static func applyGameDetails(
		index: Int = 0,
		configuration: UITestConfiguration = .default
	) async throws -> GameDetailsPage {
		let list = try await apply(configuration: configuration)
		return try await list.tapGameRow(at: index)
	}

	private static func popToRoot(in app: XCUIApplication) {
		let listScreen = app.descendants(matching: .any)
			.matching(identifier: AccessibilityIdentifier.GamesList.screen)
			.firstMatch
		if listScreen.waitForExistence(timeout: 0.5) {
			return
		}
		let emptyState = app.descendants(matching: .any)
			.matching(identifier: AccessibilityIdentifier.GamesList.emptyState)
			.firstMatch
		if emptyState.waitForExistence(timeout: 0.5) {
			return
		}
		// Do not use `element(boundBy: 0)` + `isHittable` in a `for … where` filter.
		// After the first pop the Games Library bar has no buttons; XCTest throws
		// "No matches found for Descendants matching type Button" instead of false.
		for _ in 0 ..< 5 {
			let navButtons = app.navigationBars.buttons
			guard navButtons.count > 0 else { return }
			let backButton = navButtons.firstMatch
			guard backButton.exists else { return }
			backButton.tap()
			if listScreen.waitForExistence(timeout: 0.5) { return }
			if emptyState.waitForExistence(timeout: 0.3) { return }
		}
	}
}
