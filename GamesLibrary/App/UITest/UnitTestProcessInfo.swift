#if DEBUG
import Foundation

/// Detects hosted unit tests (Swift Testing or XCTest with `TEST_HOST`).
enum UnitTestProcessInfo {
	nonisolated static var isRunningUnitTests: Bool {
		isRunningUnitTests(environment: ProcessInfo.processInfo.environment)
	}

	nonisolated static func isRunningUnitTests(environment: [String: String]) -> Bool {
		if environment["IS_TESTING"] == "1" {
			return true
		}

		if let bundlePath = environment["XCTestBundlePath"], !bundlePath.isEmpty {
			return true
		}

		if let configurationPath = environment["XCTestConfigurationFilePath"], !configurationPath.isEmpty {
			return true
		}

		return false
	}
}
#endif
