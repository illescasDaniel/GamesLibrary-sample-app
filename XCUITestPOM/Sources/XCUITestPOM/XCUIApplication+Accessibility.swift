import XCTest
import AccessibilityIdentifiers

@MainActor
extension XCUIApplication {
	public func waitForUITestReady(
		sessionGeneration: Int,
		timeout: TimeInterval = UITestTimeout.screen
	) throws {
		let identifier = AccessibilityIdentifier.UITest.ready(sessionGeneration: sessionGeneration)
		try waitForElement(matching: identifier, timeout: timeout)
	}

	public func element(matching identifier: String) -> XCUIElement {
		descendants(matching: .any).matching(identifier: identifier).firstMatch
	}

	public func elements(matchingIdentifierPrefix prefix: String) -> XCUIElementQuery {
		descendants(matching: .any)
			.matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
	}

	@discardableResult
	public func waitForElement(
		matching identifier: String,
		timeout: TimeInterval = UITestTimeout.screen
	) throws -> XCUIElement {
		try element(matching: identifier)
			.requireExistence(identifier: identifier, timeout: timeout)
	}

	@discardableResult
	public func waitForElements(
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

	public func requireNoElements(
		matchingIdentifierPrefix prefix: String,
		timeout: TimeInterval = UITestTimeout.absence
	) throws {
		try elements(matchingIdentifierPrefix: prefix).firstMatch
			.requireAbsence(identifier: "\(prefix)*", timeout: timeout)
	}
}
