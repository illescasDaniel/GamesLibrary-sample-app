import XCTest
import AccessibilityIdentifiers

final class GameDetailsUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenGameRowTappedThenOpensDetails() async throws {
		let details = try await AppLauncher.launchGameDetails()

		_ = try await details.screen
	}

	@MainActor
	func testGivenDetailsWhenLoadedThenShowsDescriptionAndWebsite() async throws {
		let details = try await AppLauncher.launchGameDetails()

		_ = try await details.description
		_ = try await details.websiteLink
	}

	@MainActor
	func testGivenDetailsWhenLoadedThenShowsMetadataChips() async throws {
		let details = try await AppLauncher.launchGameDetails()

		_ = try await details.rating
		_ = try await details.year
		_ = try await details.playtime
		_ = try await details.esrb
		_ = try await details.platforms
	}

	@MainActor
	func testGivenDetailsFailureWhenOpenedThenShowsErrorWithRetry() async throws {
		let details = try await AppLauncher.launchGameDetails(
			configuration: .init(gameDetails: .failingThenSucceeding())
		)

		_ = try await details.error
		_ = try await details.retryButton
	}

	@MainActor
	func testGivenDetailsFailureWhenRetryTappedThenShowsContent() async throws {
		let details = try await AppLauncher.launchGameDetails(
			configuration: .init(gameDetails: .failingThenSucceeding())
		)

		_ = try await details.error
		_ = try await details.tapRetry()

		_ = try await details.description
		_ = try await details.websiteLink
	}
}
