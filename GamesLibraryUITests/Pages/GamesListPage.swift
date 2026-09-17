import XCTest
import AccessibilityIdentifiers

@MainActor
struct GamesListPage {
	let app: XCUIApplication

	var screen: XCUIElement {
		app.element(matching: AccessibilityIdentifier.GamesList.screen)
	}

	var emptyState: XCUIElement {
		app.element(matching: AccessibilityIdentifier.GamesList.emptyState)
	}

	var gameRows: XCUIElementQuery {
		app.elements(matchingIdentifierPrefix: AccessibilityIdentifier.GamesList.gameRowPrefix)
	}

	@discardableResult
	func waitForScreen(timeout: TimeInterval = 10) -> Bool {
		screen.waitForExistence(timeout: timeout)
	}

	@discardableResult
	func waitForEmptyState(timeout: TimeInterval = 20) -> Bool {
		emptyState.waitForExistence(timeout: timeout)
	}

	@discardableResult
	func waitForGameRows(timeout: TimeInterval = 15) -> Bool {
		gameRows.firstMatch.waitForExistence(timeout: timeout)
	}

	@discardableResult
	func tapFirstGameRow() -> GameDetailsPage {
		gameRows.firstMatch.tap()
		return GameDetailsPage(app: app)
	}

	func hasGameRows(timeout: TimeInterval = 2) -> Bool {
		gameRows.firstMatch.waitForExistence(timeout: timeout)
	}
}
