import XCTest
import AccessibilityIdentifiers

final class GamesLibraryUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenLaunchedThenShowsTitle() {
		let list = launchGamesList()

		XCTAssertTrue(list.waitForScreen())
	}

	@MainActor
	func testGivenGamesListWhenLoadedThenShowsRows() {
		let list = launchGamesList()

		XCTAssertTrue(list.waitForGameRows())
	}

	@MainActor
	func testGivenGamesListWhenGameRowTappedThenOpensDetails() {
		let list = launchGamesList()
		XCTAssertTrue(list.waitForGameRows())

		list.tapFirstGameRow()

		let details = GameDetailsPage(app: list.app)
		XCTAssertTrue(details.waitForScreen())
	}

	@MainActor
	func testGivenGamesListWhenEmptyResultsForcedThenShowsNoResults() {
		// SwiftUI `.searchable` text entry is unreliable in XCUITest; configure an empty
		// StubGamesRepository via launch environment instead of seeding ViewModel.searchText.
		let list = launchGamesList(forceEmptyResults: true)

		XCTAssertTrue(list.waitForEmptyState())
		XCTAssertFalse(list.hasGameRows())
	}

	@MainActor
	private func launchGamesList(forceEmptyResults: Bool = false) -> GamesListPage {
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
