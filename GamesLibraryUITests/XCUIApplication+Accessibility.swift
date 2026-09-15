import XCTest

extension XCUIApplication {
	func element(matching identifier: String) -> XCUIElement {
		descendants(matching: .any).matching(identifier: identifier).firstMatch
	}

	func elements(matchingIdentifierPrefix prefix: String) -> XCUIElementQuery {
		descendants(matching: .any)
			.matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
	}
}
