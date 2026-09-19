import XCTest
import AccessibilityIdentifiers
import XCUITestPOM

@MainActor
struct GameDetailsPage {
	let app: XCUIApplication

	@MainActor
	struct Header {
		let app: XCUIApplication

		var rating: XCUIElement {
			get async throws {
				try await app.waitForElementAsync(
					matching: AccessibilityIdentifier.GameDetails.rating,
					timeout: UITestTimeout.content
				)
			}
		}

		var year: XCUIElement {
			get async throws {
				try await app.waitForElementAsync(
					matching: AccessibilityIdentifier.GameDetails.year,
					timeout: UITestTimeout.content
				)
			}
		}

		var playtime: XCUIElement {
			get async throws {
				try await app.waitForElementAsync(
					matching: AccessibilityIdentifier.GameDetails.playtime,
					timeout: UITestTimeout.content
				)
			}
		}

		var esrb: XCUIElement {
			get async throws {
				try await app.waitForElementAsync(
					matching: AccessibilityIdentifier.GameDetails.esrb,
					timeout: UITestTimeout.content
				)
			}
		}

		var platforms: XCUIElement {
			get async throws {
				try await app.waitForElementAsync(
					matching: AccessibilityIdentifier.GameDetails.platforms,
					timeout: UITestTimeout.content
				)
			}
		}
	}

	@MainActor
	struct Content {
		let app: XCUIApplication

		var description: XCUIElement {
			get async throws {
				try await app.waitForElementAsync(
					matching: AccessibilityIdentifier.GameDetails.description,
					timeout: UITestTimeout.content
				)
			}
		}

		var websiteLink: XCUIElement {
			get async throws {
				try await app.waitForElementAsync(
					matching: AccessibilityIdentifier.GameDetails.websiteLink,
					timeout: UITestTimeout.content
				)
			}
		}
	}

	var header: Header { Header(app: app) }
	var content: Content { Content(app: app) }

	/// Waits until the details screen exists; throws if it does not appear in time.
	var screen: XCUIElement {
		get async throws {
			try await app.waitForElementAsync(
				matching: AccessibilityIdentifier.GameDetails.screen,
				timeout: UITestTimeout.screen
			)
		}
	}

	var loading: XCUIElement {
		get async throws {
			try await app.waitForElementAsync(
				matching: AccessibilityIdentifier.GameDetails.loading,
				timeout: UITestTimeout.screen
			)
		}
	}

	var error: XCUIElement {
		get async throws {
			try await app.waitForElementAsync(
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
			return try await button.requireExistenceAsync(
				identifier: AccessibilityIdentifier.GameDetails.error,
				timeout: UITestTimeout.content
			)
		}
	}

	@discardableResult
	func tapRetry() async throws -> Self {
		let button = try await retryButton
		try await button.requireAsync(
			identifier: AccessibilityIdentifier.GameDetails.error,
			checks: [.tappable()],
			in: app
		)
		button.tap()
		return self
	}
}
