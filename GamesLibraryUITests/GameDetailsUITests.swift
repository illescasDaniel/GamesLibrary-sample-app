import AccessibilityIdentifiers
import ASTKXCTest
import XCTest

final class GameDetailsUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testGivenGamesListWhenGameRowTappedThenOpensDetails() async throws {
		let details = try await AppLauncher.applyGameDetails()

		let screen = try await details.screen
		try await screen.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.screen,
			checks: [.visible()],
			in: details.app
		)
	}

	@MainActor
	func testGivenDetailsWhenLoadedThenShowsDescriptionAndWebsite() async throws {
		let details = try await AppLauncher.applyGameDetails()

		async let description = details.content.description
		async let websiteLink = details.content.websiteLink
		let (descriptionElement, websiteElement) = try await (description, websiteLink)
		async let descriptionCheck = descriptionElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.description,
			checks: [.visible(scroll: true), .nonEmptyText()],
			in: details.app
		)
		async let websiteCheck = websiteElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.websiteLink,
			checks: [.visible(scroll: true), .tappable()],
			in: details.app
		)
		_ = try await (descriptionCheck, websiteCheck)
	}

	@MainActor
	func testGivenDetailsWhenLoadedThenShowsMetadataChips() async throws {
		let details = try await AppLauncher.applyGameDetails()

		async let rating = details.header.rating
		async let year = details.header.year
		async let playtime = details.header.playtime
		async let esrb = details.header.esrb
		async let platforms = details.header.platforms
		let (ratingElement, yearElement, playtimeElement, esrbElement, platformsElement) = try await (
			rating, year, playtime, esrb, platforms
		)
		async let ratingCheck = ratingElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.rating,
			checks: [.visible(), .nonEmptyText()],
			in: details.app
		)
		async let yearCheck = yearElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.year,
			checks: [.visible(), .nonEmptyText()],
			in: details.app
		)
		async let playtimeCheck = playtimeElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.playtime,
			checks: [.visible(), .nonEmptyText()],
			in: details.app
		)
		async let esrbCheck = esrbElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.esrb,
			checks: [.visible(), .nonEmptyText()],
			in: details.app
		)
		async let platformsCheck = platformsElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.platforms,
			checks: [.visible()],
			in: details.app
		)
		_ = try await (ratingCheck, yearCheck, playtimeCheck, esrbCheck, platformsCheck)
	}

	@MainActor
	func testGivenDetailsFailureWhenOpenedThenShowsErrorWithRetry() async throws {
		let details = try await AppLauncher.applyGameDetails(
			configuration: .init(gameDetails: .failingThenSucceeding())
		)

		async let error = details.error
		async let retryButton = details.retryButton
		let (errorElement, retryElement) = try await (error, retryButton)
		async let errorCheck = errorElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.error,
			checks: [.visible()],
			in: details.app
		)
		async let retryCheck = retryElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.error,
			checks: [.visible(), .tappable()],
			in: details.app
		)
		_ = try await (errorCheck, retryCheck)
	}

	@MainActor
	func testGivenDetailsFailureWhenRetryTappedThenShowsContent() async throws {
		let details = try await AppLauncher.applyGameDetails(
			configuration: .init(gameDetails: .failingThenSucceeding())
		)

		let error = try await details.error
		_ = try await details.tapRetry()

		try await error.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.error,
			checks: [.exists(false)],
			in: details.app
		)

		async let description = details.content.description
		async let websiteLink = details.content.websiteLink
		let (descriptionElement, websiteElement) = try await (description, websiteLink)
		async let descriptionCheck = descriptionElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.description,
			checks: [.visible(scroll: true), .nonEmptyText()],
			in: details.app
		)
		async let websiteCheck = websiteElement.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.websiteLink,
			checks: [.visible(scroll: true), .tappable()],
			in: details.app
		)
		_ = try await (descriptionCheck, websiteCheck)
	}
}
