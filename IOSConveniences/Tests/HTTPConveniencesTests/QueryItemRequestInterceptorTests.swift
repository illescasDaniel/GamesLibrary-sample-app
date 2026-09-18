import Foundation
import Testing
import HTTPConveniences

@Suite
struct QueryItemRequestInterceptorTests {

	@Test
	func `Given Request URL When Intercepted Then Query Item Is Appended`() async throws {
		var request = URLRequest(url: URL(string: "https://example.com/games")!)
		let interceptor = QueryItemRequestInterceptor(name: "key", value: "abc")

		interceptor.intercept(request: &request)

		let items = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems
		#expect(items == [URLQueryItem(name: "key", value: "abc")])
	}

	@Test
	func `Given Existing Query When Intercepted Then Item Is Appended`() async throws {
		var request = URLRequest(url: URL(string: "https://example.com/games?page=1")!)
		let interceptor = QueryItemRequestInterceptor(name: "key", value: "abc")

		interceptor.intercept(request: &request)

		let items = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems
		#expect(items == [
			URLQueryItem(name: "page", value: "1"),
			URLQueryItem(name: "key", value: "abc"),
		])
	}
}
