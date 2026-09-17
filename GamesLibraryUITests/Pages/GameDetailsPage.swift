import XCTest
import AccessibilityIdentifiers

@MainActor
struct GameDetailsPage {
	let app: XCUIApplication

	var screen: XCUIElement {
		app.element(matching: AccessibilityIdentifier.GameDetails.screen)
	}

	@discardableResult
	func waitForScreen(timeout: TimeInterval = 10) -> Bool {
		screen.waitForExistence(timeout: timeout)
	}
}
