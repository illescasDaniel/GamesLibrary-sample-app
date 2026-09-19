import Testing
@testable import GamesLibrary

@Suite
struct UnitTestProcessInfoTests {
	@Test
	func `Given XCTestBundlePath When Checked Then Unit Tests Are Detected`() {
		#expect(
			UnitTestProcessInfo.isRunningUnitTests(
				environment: ["XCTestBundlePath": "PlugIns/GamesLibraryTests.xctest"]
			)
		)
	}

	@Test
	func `Given IS_TESTING When Checked Then Unit Tests Are Detected`() {
		#expect(UnitTestProcessInfo.isRunningUnitTests(environment: ["IS_TESTING": "1"]))
	}

	@Test
	func `Given XCTestConfigurationFilePath When Checked Then Unit Tests Are Detected`() {
		#expect(
			UnitTestProcessInfo.isRunningUnitTests(
				environment: ["XCTestConfigurationFilePath": "/tmp/xctest.plist"]
			)
		)
	}

	@Test
	func `Given UITESTING When Checked Then Unit Tests Are Not Detected`() {
		#expect(!UnitTestProcessInfo.isRunningUnitTests(environment: ["UITESTING": "1"]))
	}

	@Test
	func `Given Empty Environment When Checked Then Unit Tests Are Not Detected`() {
		#expect(!UnitTestProcessInfo.isRunningUnitTests(environment: [:]))
	}
}
