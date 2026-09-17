import XCTest

final class GameDetailsUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenGameRowTappedThenOpensDetails() {
		let list = AppLauncher.launchGamesList()
		XCTAssertTrue(list.waitForGameRows())

		let details = list.tapFirstGameRow()

		XCTAssertTrue(details.waitForScreen())
	}
}
