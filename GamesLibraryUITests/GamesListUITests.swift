import XCTest
import AccessibilityIdentifiers

final class GamesListUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenLaunchedThenShowsTitle() throws {
		let list = try AppLauncher.apply()

		_ = try list.screen
	}

	@MainActor
	func testGivenGamesListWhenLoadedThenShowsRows() throws {
		let list = try AppLauncher.apply()

		_ = try list.gameRows
	}

	@MainActor
	func testGivenGamesListWhenEmptyResultsForcedThenShowsNoResults() throws {
		// SwiftUI `.searchable` text entry is unreliable in XCUITest; configure an empty
		// canned `(1, "")` response instead of seeding ViewModel.searchText.
		let list = try AppLauncher.apply(
			configuration: .init(gamesList: .empty)
		)

		_ = try list.emptyState
		try list.requireNoGameRows()
	}
}
