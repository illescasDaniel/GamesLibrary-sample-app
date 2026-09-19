import AccessibilityIdentifiers
import ASTKXCTest
import XCTest

final class GamesListUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenLaunchedThenShowsTitle() async throws {
		let list = try await AppLauncher.apply()

		let screen = try await list.screen
		try await screen.requireAsync(
			identifier: AccessibilityIdentifier.GamesList.screen,
			checks: [.visible()],
			in: list.app
		)
	}

	@MainActor
	func testGivenGamesListWhenLoadedThenShowsRows() async throws {
		let list = try await AppLauncher.apply()

		let row = try await list.gameRow(at: 0)
		async let name = row.name
		async let thumbnail = row.thumbnail
		let (nameElement, thumbnailElement) = try await (name, thumbnail)
		async let nameCheck = nameElement.requireAsync(
			identifier: AccessibilityIdentifier.GamesList.GameRow.name,
			checks: [.visible(), .nonEmptyText()],
			in: list.app
		)
		async let thumbnailCheck = thumbnailElement.requireAsync(
			identifier: AccessibilityIdentifier.GamesList.GameRow.thumbnail,
			checks: [.visible()],
			in: list.app
		)
		_ = try await (nameCheck, thumbnailCheck)
	}

	@MainActor
	func testGivenGamesListWhenEmptyResultsForcedThenShowsNoResults() async throws {
		// SwiftUI `.searchable` text entry is unreliable in XCUITest; configure an empty
		// canned `(1, "")` response instead of seeding ViewModel.searchText.
		let list = try await AppLauncher.apply(
			configuration: .init(gamesList: .empty)
		)

		let emptyState = try await list.emptyState
		try await emptyState.requireAsync(
			identifier: AccessibilityIdentifier.GamesList.emptyState,
			checks: [.visible()],
			in: list.app
		)
		try await list.requireNoGameRows()
	}
}
