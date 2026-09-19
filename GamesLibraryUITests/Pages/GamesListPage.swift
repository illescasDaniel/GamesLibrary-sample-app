import XCTest
import AccessibilityIdentifiers
import XCUITestPOM

@MainActor
struct GamesListPage {
	let app: XCUIApplication

	@MainActor
	struct GameRow {
		let root: XCUIElement
		let app: XCUIApplication

		var name: XCUIElement {
			get async throws {
				try await childElement(
					matching: AccessibilityIdentifier.GamesList.GameRow.name
				)
			}
		}

		var thumbnail: XCUIElement {
			get async throws {
				try await childElement(
					matching: AccessibilityIdentifier.GamesList.GameRow.thumbnail
				)
			}
		}

		var rating: XCUIElement {
			get async throws {
				try await childElement(
					matching: AccessibilityIdentifier.GamesList.GameRow.rating
				)
			}
		}

		var year: XCUIElement {
			get async throws {
				try await childElement(
					matching: AccessibilityIdentifier.GamesList.GameRow.year
				)
			}
		}

		@discardableResult
		func tap() async throws -> GameDetailsPage {
			try await root.requireAsync(
				identifier: root.identifier,
				checks: [.tappable()],
				in: app
			)
			root.tap()
			return GameDetailsPage(app: app)
		}

		private func childElement(matching identifier: String) async throws -> XCUIElement {
			let element = root.descendants(matching: .any)
				.matching(identifier: identifier)
				.firstMatch
			return try await element.requireExistenceAsync(
				identifier: identifier,
				timeout: UITestTimeout.content
			)
		}
	}

	/// Waits until the list screen exists; throws if it does not appear in time.
	var screen: XCUIElement {
		get async throws {
			try await app.waitForElementAsync(
				matching: AccessibilityIdentifier.GamesList.screen,
				timeout: UITestTimeout.screen
			)
		}
	}

	/// Waits until the empty state exists; throws if it does not appear in time.
	var emptyState: XCUIElement {
		get async throws {
			try await app.waitForElementAsync(
				matching: AccessibilityIdentifier.GamesList.emptyState,
				timeout: UITestTimeout.emptyState
			)
		}
	}

	/// Waits until at least one game row exists; throws if none appear in time.
	var gameRows: XCUIElementQuery {
		get async throws {
			try await app.waitForElementsAsync(
				matchingIdentifierPrefix: AccessibilityIdentifier.GamesList.gameRowPrefix,
				timeout: UITestTimeout.content
			)
		}
	}

	func gameRow(at index: Int) async throws -> GameRow {
		let rows = try await gameRows
		let row = rows.element(boundBy: index)
		_ = try await row.requireExistenceAsync(
			identifier: "\(AccessibilityIdentifier.GamesList.gameRowPrefix)[\(index)]",
			timeout: UITestTimeout.content
		)
		return GameRow(root: row, app: app)
	}

	func gameRow(id: Int) async throws -> GameRow {
		let identifier = AccessibilityIdentifier.gameRow(id: id)
		let row = app.element(matching: identifier)
		_ = try await row.requireExistenceAsync(
			identifier: identifier,
			timeout: UITestTimeout.content
		)
		return GameRow(root: row, app: app)
	}

	@discardableResult
	func tapGameRow(at index: Int = 0) async throws -> GameDetailsPage {
		try await gameRow(at: index).tap()
	}

	@discardableResult
	func tapFirstGameRow() async throws -> GameDetailsPage {
		try await tapGameRow(at: 0)
	}

	func requireNoGameRows(timeout: TimeInterval = UITestTimeout.absence) async throws {
		try await app.requireNoElementsAsync(
			matchingIdentifierPrefix: AccessibilityIdentifier.GamesList.gameRowPrefix,
			timeout: timeout
		)
	}
}
