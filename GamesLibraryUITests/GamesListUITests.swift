import XCTest

final class GamesListUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenLaunchedThenShowsTitle() {
		let list = AppLauncher.launchGamesList()

		XCTAssertTrue(list.waitForScreen())
	}

	@MainActor
	func testGivenGamesListWhenLoadedThenShowsRows() {
		let list = AppLauncher.launchGamesList()

		XCTAssertTrue(list.waitForGameRows())
	}

	@MainActor
	func testGivenGamesListWhenEmptyResultsForcedThenShowsNoResults() {
		// SwiftUI `.searchable` text entry is unreliable in XCUITest; configure an empty
		// StubGamesRepository via launch environment instead of seeding ViewModel.searchText.
		let list = AppLauncher.launchGamesList(forceEmptyResults: true)

		XCTAssertTrue(list.waitForEmptyState())
		XCTAssertFalse(list.hasGameRows())
	}
}
