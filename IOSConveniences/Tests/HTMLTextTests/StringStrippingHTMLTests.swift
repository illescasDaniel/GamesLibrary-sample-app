import Testing
import HTMLText

@Suite
struct StringStrippingHTMLTests {

	@Test
	func `Given Paragraph Tags When Stripped Then Inner Text Remains`() {
		#expect("<p>Hello</p>".strippingHTML() == "Hello")
	}

	@Test
	func `Given Plain Text When Stripped Then Text Is Unchanged`() {
		let input = "Plain text without tags"
		#expect(input.strippingHTML() == input)
	}

	@Test
	func `Given Nested Inline Tags When Stripped Then Text Is Joined`() {
		#expect("<p>Hello <strong>world</strong></p>".strippingHTML() == "Hello world")
	}

	@Test
	func `Given Named Entities When Stripped Then Characters Are Decoded`() {
		#expect("A &amp; B".strippingHTML() == "A & B")
		#expect("A&nbsp;B".strippingHTML() == "A B")
	}

	@Test
	func `Given Numeric Entities When Stripped Then Characters Are Decoded`() {
		#expect("&#39;".strippingHTML() == "'")
		#expect("&#x27;".strippingHTML() == "'")
	}

	@Test
	func `Given Line Break Tags When Stripped Then Newline Separates Words`() {
		#expect("a<br>b".strippingHTML() == "a\nb")
		#expect("a<br/>b".strippingHTML() == "a\nb")
	}

	@Test
	func `Given Adjacent Paragraphs When Stripped Then Two Lines Remain`() {
		#expect("<p>One</p><p>Two</p>".strippingHTML() == "One\nTwo")
	}

	@Test
	func `Given Script And Style When Stripped Then Bodies Are Discarded`() {
		#expect("Hello<script>alert(1)</script>world".strippingHTML() == "Helloworld")
		#expect("Hello<style>p{color:red}</style>world".strippingHTML() == "Helloworld")
	}

	@Test
	func `Given Unclosed Tag When Stripped Then Following Text Remains`() {
		#expect("<p>Hello".strippingHTML() == "Hello")
	}

	@Test
	func `Given Empty And Degenerate Markup When Stripped Then Does Not Crash`() {
		#expect("".strippingHTML() == "")
		#expect("<>".strippingHTML() == "")
	}
}
