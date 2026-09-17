import XCTest
import AccessibilityIdentifiers

@MainActor
struct GamesListPage {
	let app: XCUIApplication

	/// Waits until the list screen exists; throws if it does not appear in time.
	var screen: XCUIElement {
		get async throws {
			let identifier = AccessibilityIdentifier.GamesList.screen
			return try app.element(matching: identifier)
				.requireExistence(identifier: identifier, timeout: UITestTimeout.screen)
		}
	}

	/// Waits until the empty state exists; throws if it does not appear in time.
	var emptyState: XCUIElement {
		get async throws {
			let identifier = AccessibilityIdentifier.GamesList.emptyState
			return try app.element(matching: identifier)
				.requireExistence(identifier: identifier, timeout: UITestTimeout.emptyState)
		}
	}

	/// Waits until at least one game row exists; throws if none appear in time.
	var gameRows: XCUIElementQuery {
		get async throws {
			let prefix = AccessibilityIdentifier.GamesList.gameRowPrefix
			let query = app.elements(matchingIdentifierPrefix: prefix)
			_ = try query.firstMatch.requireExistence(
				identifier: "\(prefix)*",
				timeout: UITestTimeout.content
			)
			return query
		}
	}

	@discardableResult
	func tapFirstGameRow() async throws -> GameDetailsPage {
		let rows = try await gameRows
		rows.firstMatch.tap()
		return GameDetailsPage(app: app)
	}

	func requireNoGameRows(timeout: TimeInterval = UITestTimeout.absence) throws {
		let prefix = AccessibilityIdentifier.GamesList.gameRowPrefix
		try app.elements(matchingIdentifierPrefix: prefix).firstMatch
			.requireAbsence(identifier: "\(prefix)*", timeout: timeout)
	}
}
