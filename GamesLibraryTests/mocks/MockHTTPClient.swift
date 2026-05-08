import Foundation
@testable import GamesLibrary
import BetterLogger
import HTTIES

final class MockHTTPClient: HTTPClient, @unchecked Sendable {
	var result: Any?
	var error: (any Error)?
	var lastRequest: HTTPURLRequest?

	func sendRequest(_ httpURLRequest: HTTPURLRequest) async throws -> (Data, HTTPURLResponse) {
		lastRequest = httpURLRequest
		if let error { throw error }
		throw MockError.notConfigured
	}

	func sendRequest<T: Decodable>(
		_ httpURLRequest: HTTPURLRequest,
		decoding: T.Type,
		decoder: any DecodableDecoder
	) async throws -> T {
		lastRequest = httpURLRequest
		if let error { throw error }
		if let result = result as? T {
			return result
		}
		throw MockError.notConfigured
	}
}
