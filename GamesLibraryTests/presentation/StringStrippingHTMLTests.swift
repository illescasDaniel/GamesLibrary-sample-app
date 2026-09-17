import Testing
@testable import GamesLibrary

@Suite
struct StringStrippingHTMLTests {

	@Test
	func `Given HTML String When Stripped Then Plain Text Is Extracted`() {
		let result = "<p>Hello</p>".strippingHTML()

		#expect(result.contains("Hello"))
	}

	@Test
	func `Given Plain Text When Stripped Then Text Is Unchanged`() {
		let input = "Plain text without tags"

		#expect(input.strippingHTML() == input)
	}
}
