import XCTest
import AccessibilityIdentifiers

@MainActor
struct GameDetailsPage {
	let app: XCUIApplication

	/// Waits until the details screen exists; throws if it does not appear in time.
	var screen: XCUIElement {
		get async throws {
			let identifier = AccessibilityIdentifier.GameDetails.screen
			return try app.element(matching: identifier)
				.requireExistence(identifier: identifier, timeout: UITestTimeout.screen)
		}
	}
}
