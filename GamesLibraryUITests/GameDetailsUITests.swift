import XCTest

final class GameDetailsUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenGameRowTappedThenOpensDetails() async throws {
		let list = AppLauncher.launchGamesList()
		_ = try await list.gameRows

		let details = try await list.tapFirstGameRow()

		_ = try await details.screen
	}
}
