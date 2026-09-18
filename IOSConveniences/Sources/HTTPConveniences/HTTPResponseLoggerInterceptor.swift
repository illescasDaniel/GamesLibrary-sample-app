import Foundation
import HTTIES

public actor HTTPResponseLoggerInterceptor: HTTPResponseInterceptor {
	private let log: @Sendable (String) -> Void

	public init(log: @escaping @Sendable (String) -> Void) {
		self.log = log
	}

	public func intercept(
		data: Data,
		response: HTTPURLResponse,
		error: (any Error)?,
		for request: URLRequest
	) -> (Data, HTTPURLResponse, (any Error)?) {
		log(
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
