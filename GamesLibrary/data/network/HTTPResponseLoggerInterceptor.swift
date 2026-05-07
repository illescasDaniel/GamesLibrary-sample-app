//
//  HTTPResponseLoggerInterceptor.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 7/5/26.
//

#if DEBUG
import BetterLogger
import Foundation
import HTTIES

actor HTTPResponseLoggerInterceptor: HTTPResponseInterceptor {

	private let logger: BetterLogger

	public init(loggerName: String = "Data") {
		self.logger = BetterLogger(name: loggerName)
	}

	public func intercept(data: Data, response: HTTPURLResponse, error: (any Error)?, for request: URLRequest) -> (Data, HTTPURLResponse, (any Error)?) {
		logger.info(
			"""
			- Request: \(request.url?.path(percentEncoded: false) ?? "nil")
			  - Body parameters: \(request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? "nil")
			- Response: \(response.statusCode)
			  - Body content: \(String(decoding: data, as: UTF8.self))
			"""
		)
		return (data, response, error)
	}
}
#endif
