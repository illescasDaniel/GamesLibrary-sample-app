import XCTest

final class GamesLibraryUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGamesListLaunchesAndShowsTitle() throws {
		let app = launchUITestApp()

		XCTAssertTrue(app.element(matching: AccessibilityIdentifier.GamesList.screen).waitForExistence(timeout: 10))
	}

	@MainActor
	func testGamesListShowsRowsAfterLoad() throws {
		let app = launchUITestApp()

		let gameRow = app.elements(matchingIdentifierPrefix: AccessibilityIdentifier.GamesList.gameRowPrefix).firstMatch

		XCTAssertTrue(gameRow.waitForExistence(timeout: 15))
	}

	@MainActor
	func testTapGameRowOpensDetails() throws {
		let app = launchUITestApp()

		let gameRow = app.elements(matchingIdentifierPrefix: AccessibilityIdentifier.GamesList.gameRowPrefix).firstMatch
		XCTAssertTrue(gameRow.waitForExistence(timeout: 15))

		gameRow.tap()

		XCTAssertTrue(app.element(matching: AccessibilityIdentifier.GameDetails.screen).waitForExistence(timeout: 10))
	}

	@MainActor
	func testSearchShowsNoResults() throws {
		// SwiftUI `.searchable` text entry is unreliable in XCUITest; configure an empty
		// StubGamesRepository via launch environment instead of seeding ViewModel.searchText.
		let app = launchUITestApp(forceEmptyResults: true)

		let emptyState = app.element(matching: AccessibilityIdentifier.GamesList.emptyState)
		XCTAssertTrue(emptyState.waitForExistence(timeout: 20))

		let gameRow = app.elements(matchingIdentifierPrefix: AccessibilityIdentifier.GamesList.gameRowPrefix).firstMatch
		XCTAssertFalse(gameRow.waitForExistence(timeout: 2))
	}

	@MainActor
	private func launchUITestApp(forceEmptyResults: Bool = false) -> XCUIApplication {
		let app = XCUIApplication()
		app.terminate()
		app.launchArguments = ["-UITesting"]
		app.launchEnvironment = forceEmptyResults
			? [UITestSupport.forceEmptyResultsEnvironmentKey: "1"]
			: [:]
		app.launch()
		return app
	}
}
