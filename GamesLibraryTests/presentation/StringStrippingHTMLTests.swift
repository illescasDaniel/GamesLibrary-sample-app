import Testing
@testable import GamesLibrary

@Suite
struct StringStrippingHTMLTests {

    @Test
    func givenHTMLStringWhenStrippedThenPlainTextIsExtracted() {
        let result = "<p>Hello</p>".strippingHTML()

        #expect(result.contains("Hello"))
    }

    @Test
    func givenPlainTextWhenStrippedThenTextIsUnchanged() {
        let input = "Plain text without tags"

        #expect(input.strippingHTML() == input)
    }
}
