import Foundation
import HTTIES

/// Appends a single query item to the request URL.
public struct QueryItemRequestInterceptor: HTTPInoutRequestInterceptor {
	public let name: String
	public let value: String

	public init(name: String, value: String) {
		self.name = name
		self.value = value
	}

	public func intercept(request: inout URLRequest) {
		guard
			let url = request.url?.absoluteString,
			var urlComponents = URLComponents(string: url)
		else {
			return
		}

		urlComponents.queryItems = (urlComponents.queryItems ?? []) + [
			URLQueryItem(name: name, value: value),
		]

		guard let validURL = urlComponents.url else {
			return
		}
		request.url = validURL
	}
}
