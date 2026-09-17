#if DEBUG
import BetterLogger
import Foundation
import HTTIES

actor HTTPResponseLoggerInterceptor: HTTPResponseInterceptor {
	private let logger: BetterLogger

	init(logger: BetterLogger) {
		self.logger = logger
	}

	func intercept(data: Data, response: HTTPURLResponse, error: (any Error)?, for request: URLRequest) -> (Data, HTTPURLResponse, (any Error)?) {
		logger.info(
			"""
			- Request: \(request.url?.absoluteString ?? "nil")
			  - Body parameters: \(request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? "nil")
			- Response: \(response.statusCode)
			  - Body content: \(String(decoding: data, as: UTF8.self))
			"""
		)
		return (data, response, error)
	}
}
#endif
