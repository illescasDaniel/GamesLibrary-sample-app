import XCTest
import AccessibilityIdentifiers

final class GameDetailsUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenGameRowTappedThenOpensDetails() async throws {
		let details = try await AppLauncher.applyGameDetails()

		_ = try await details.screen
	}

	@MainActor
	func testGivenDetailsWhenLoadedThenShowsDescriptionAndWebsite() async throws {
		let details = try await AppLauncher.applyGameDetails()

		async let description = details.description
		async let websiteLink = details.websiteLink
		_ = try await (description, websiteLink)
	}

	@MainActor
	func testGivenDetailsWhenLoadedThenShowsMetadataChips() async throws {
		let details = try await AppLauncher.applyGameDetails()

		async let rating = details.rating
		async let year = details.year
		async let playtime = details.playtime
		async let esrb = details.esrb
		async let platforms = details.platforms
		_ = try await (rating, year, playtime, esrb, platforms)
	}

	@MainActor
	func testGivenDetailsFailureWhenOpenedThenShowsErrorWithRetry() async throws {
		let details = try await AppLauncher.applyGameDetails(
			configuration: .init(gameDetails: .failingThenSucceeding())
		)

		async let error = details.error
		async let retryButton = details.retryButton
		_ = try await (error, retryButton)
	}

	@MainActor
	func testGivenDetailsFailureWhenRetryTappedThenShowsContent() async throws {
		let details = try await AppLauncher.applyGameDetails(
			configuration: .init(gameDetails: .failingThenSucceeding())
		)

		_ = try await details.error
		_ = try await details.tapRetry()

		async let description = details.description
		async let websiteLink = details.websiteLink
		_ = try await (description, websiteLink)
	}
}
