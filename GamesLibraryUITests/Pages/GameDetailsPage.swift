import XCTest
import AccessibilityIdentifiers

@MainActor
struct GameDetailsPage {
	let app: XCUIApplication

	/// Waits until the details screen exists; throws if it does not appear in time.
	var screen: XCUIElement {
		get async throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GameDetails.screen,
				timeout: UITestTimeout.screen
			)
		}
	}

	var loading: XCUIElement {
		get async throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GameDetails.loading,
				timeout: UITestTimeout.screen
			)
		}
	}

	var error: XCUIElement {
		get async throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GameDetails.error,
				timeout: UITestTimeout.content
			)
		}
	}

	/// Retry is the button that inherits the error root identifier
	/// (`ContentUnavailableView` does not expose a separate child id).
	var retryButton: XCUIElement {
		get async throws {
			let button = app.descendants(matching: .button)
				.matching(identifier: AccessibilityIdentifier.GameDetails.error)
				.firstMatch
			return try button.requireExistence(
				identifier: AccessibilityIdentifier.GameDetails.error,
				timeout: UITestTimeout.content
			)
		}
	}

	var description: XCUIElement {
		get async throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GameDetails.description,
				timeout: UITestTimeout.content
			)
		}
	}

	var websiteLink: XCUIElement {
		get async throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GameDetails.websiteLink,
				timeout: UITestTimeout.content
			)
		}
	}

	var rating: XCUIElement {
		get async throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GameDetails.rating,
				timeout: UITestTimeout.content
			)
		}
	}

	var year: XCUIElement {
		get async throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GameDetails.year,
				timeout: UITestTimeout.content
			)
		}
	}

	var playtime: XCUIElement {
		get async throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GameDetails.playtime,
				timeout: UITestTimeout.content
			)
		}
	}

	var esrb: XCUIElement {
		get async throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GameDetails.esrb,
				timeout: UITestTimeout.content
			)
		}
	}

	var platforms: XCUIElement {
		get async throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GameDetails.platforms,
				timeout: UITestTimeout.content
			)
		}
	}

	@discardableResult
	func tapRetry() async throws -> Self {
		let button = try await retryButton
		button.tap()
		return self
	}
}
