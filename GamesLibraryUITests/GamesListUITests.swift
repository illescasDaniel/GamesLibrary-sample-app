import XCTest
import AccessibilityIdentifiers

final class GamesListUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenLaunchedThenShowsTitle() async throws {
		let list = try await AppLauncher.apply()

		_ = try await list.screen
	}

	@MainActor
	func testGivenGamesListWhenLoadedThenShowsRows() async throws {
		let list = try await AppLauncher.apply()

		_ = try await list.gameRows
	}

	@MainActor
	func testGivenGamesListWhenEmptyResultsForcedThenShowsNoResults() async throws {
		// SwiftUI `.searchable` text entry is unreliable in XCUITest; configure an empty
		// canned `(1, "")` response instead of seeding ViewModel.searchText.
		let list = try await AppLauncher.apply(
			configuration: .init(gamesList: .empty)
		)

		_ = try await list.emptyState
		try await list.requireNoGameRows()
	}
}
