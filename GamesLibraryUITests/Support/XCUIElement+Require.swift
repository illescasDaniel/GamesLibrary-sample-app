import XCTest

enum UITestElementError: Error, LocalizedError {
	case notFound(identifier: String, timeout: TimeInterval)
	case unexpectedlyPresent(identifier: String, timeout: TimeInterval)

	var errorDescription: String? {
		switch self {
		case .notFound(let identifier, let timeout):
			"Element '\(identifier)' not found within \(timeout)s"
		case .unexpectedlyPresent(let identifier, let timeout):
			"Element '\(identifier)' still present after \(timeout)s"
		}
	}
}

enum UITestTimeout {
	static let screen: TimeInterval = 10
	static let content: TimeInterval = 15
	static let emptyState: TimeInterval = 20
	static let absence: TimeInterval = 2
}

@MainActor
extension XCUIElement {
	@discardableResult
	func requireExistence(
		identifier: String,
		timeout: TimeInterval
	) throws -> XCUIElement {
		guard waitForExistence(timeout: timeout) else {
			throw UITestElementError.notFound(identifier: identifier, timeout: timeout)
		}
		return self
	}

	func requireAbsence(
		identifier: String,
		timeout: TimeInterval = UITestTimeout.absence
	) throws {
		if waitForExistence(timeout: timeout) {
			throw UITestElementError.unexpectedlyPresent(identifier: identifier, timeout: timeout)
		}
	}
}
