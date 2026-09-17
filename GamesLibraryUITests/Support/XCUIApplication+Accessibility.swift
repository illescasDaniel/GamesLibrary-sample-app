import XCTest

@MainActor
extension XCUIApplication {
	func element(matching identifier: String) -> XCUIElement {
		descendants(matching: .any).matching(identifier: identifier).firstMatch
	}

	func elements(matchingIdentifierPrefix prefix: String) -> XCUIElementQuery {
		descendants(matching: .any)
			.matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
	}

	@discardableResult
	func waitForElement(
		matching identifier: String,
		timeout: TimeInterval = UITestTimeout.screen
	) throws -> XCUIElement {
		try element(matching: identifier)
			.requireExistence(identifier: identifier, timeout: timeout)
	}

	@discardableResult
	func waitForElements(
		matchingIdentifierPrefix prefix: String,
		timeout: TimeInterval = UITestTimeout.content
	) throws -> XCUIElementQuery {
		let query = elements(matchingIdentifierPrefix: prefix)
		_ = try query.firstMatch.requireExistence(
			identifier: "\(prefix)*",
			timeout: timeout
		)
		return query
	}

	func requireNoElements(
		matchingIdentifierPrefix prefix: String,
		timeout: TimeInterval = UITestTimeout.absence
	) throws {
		try elements(matchingIdentifierPrefix: prefix).firstMatch
			.requireAbsence(identifier: "\(prefix)*", timeout: timeout)
	}
}
