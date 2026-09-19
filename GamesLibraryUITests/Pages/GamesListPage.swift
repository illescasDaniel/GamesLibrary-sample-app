import XCTest
import AccessibilityIdentifiers
import XCUITestPOM

@MainActor
struct GamesListPage {
	let app: XCUIApplication

	/// Waits until the list screen exists; throws if it does not appear in time.
	var screen: XCUIElement {
		get throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GamesList.screen,
				timeout: UITestTimeout.screen
			)
		}
	}

	/// Waits until the empty state exists; throws if it does not appear in time.
	var emptyState: XCUIElement {
		get throws {
			try app.waitForElement(
				matching: AccessibilityIdentifier.GamesList.emptyState,
				timeout: UITestTimeout.emptyState
			)
		}
	}

	/// Waits until at least one game row exists; throws if none appear in time.
	var gameRows: XCUIElementQuery {
		get throws {
			try app.waitForElements(
				matchingIdentifierPrefix: AccessibilityIdentifier.GamesList.gameRowPrefix,
				timeout: UITestTimeout.content
			)
		}
	}

	@discardableResult
	func tapGameRow(at index: Int = 0) throws -> GameDetailsPage {
		let rows = try gameRows
		let row = rows.element(boundBy: index)
		_ = try row.requireExistence(
			identifier: "\(AccessibilityIdentifier.GamesList.gameRowPrefix)[\(index)]",
			timeout: UITestTimeout.content
		)
		row.tap()
		return GameDetailsPage(app: app)
	}

	@discardableResult
	func tapFirstGameRow() throws -> GameDetailsPage {
		try tapGameRow(at: 0)
	}

	func requireNoGameRows(timeout: TimeInterval = UITestTimeout.absence) throws {
		try app.requireNoElements(
			matchingIdentifierPrefix: AccessibilityIdentifier.GamesList.gameRowPrefix,
			timeout: timeout
		)
	}
}
