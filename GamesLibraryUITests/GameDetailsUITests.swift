import XCTest
import AccessibilityIdentifiers

final class GameDetailsUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenGameRowTappedThenOpensDetails() throws {
		let details = try AppLauncher.applyGameDetails()

		_ = try details.screen
	}

	@MainActor
	func testGivenDetailsWhenLoadedThenShowsDescriptionAndWebsite() throws {
		let details = try AppLauncher.applyGameDetails()

		_ = try details.description
		_ = try details.websiteLink
	}

	@MainActor
	func testGivenDetailsWhenLoadedThenShowsMetadataChips() throws {
		let details = try AppLauncher.applyGameDetails()

		_ = try details.rating
		_ = try details.year
		_ = try details.playtime
		_ = try details.esrb
		_ = try details.platforms
	}

	@MainActor
	func testGivenDetailsFailureWhenOpenedThenShowsErrorWithRetry() throws {
		let details = try AppLauncher.applyGameDetails(
			configuration: .init(gameDetails: .failingThenSucceeding())
		)

		_ = try details.error
		_ = try details.retryButton
	}

	@MainActor
	func testGivenDetailsFailureWhenRetryTappedThenShowsContent() throws {
		let details = try AppLauncher.applyGameDetails(
			configuration: .init(gameDetails: .failingThenSucceeding())
		)

		_ = try details.error
		_ = try details.tapRetry()

		_ = try details.description
		_ = try details.websiteLink
	}
}
