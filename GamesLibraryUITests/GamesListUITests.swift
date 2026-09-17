import XCTest

final class GamesListUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenLaunchedThenShowsTitle() async throws {
		let list = AppLauncher.launchGamesList()

		_ = try await list.screen
	}

	@MainActor
	func testGivenGamesListWhenLoadedThenShowsRows() async throws {
		let list = AppLauncher.launchGamesList()

		_ = try await list.gameRows
	}

	@MainActor
	func testGivenGamesListWhenEmptyResultsForcedThenShowsNoResults() async throws {
		// SwiftUI `.searchable` text entry is unreliable in XCUITest; configure an empty
		// StubGamesRepository via launch environment instead of seeding ViewModel.searchText.
		let list = AppLauncher.launchGamesList(forceEmptyResults: true)

		_ = try await list.emptyState
		try list.requireNoGameRows()
	}
}
