//
//  APIKeyRequestInterceptor.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import HTTIES
import Foundation
import BetterLogger

struct APIKeyRequestInterceptor: HTTPInoutRequestInterceptor {

	let apiKey: String
	let logger: BetterLogger

	func intercept(request: inout URLRequest) {
		guard
			let url = request.url?.absoluteString,
			var urlComponents = URLComponents(string: url)
		else {
			logger.debug("Couldn't create URLComponents for \(request)")
			return
		}
		
		urlComponents.queryItems = (urlComponents.queryItems ?? []) + [
			URLQueryItem(name: "key", value: apiKey)
		]

		guard let validURL = urlComponents.url else {
			logger.debug("URL is nil after adding API key")
			return
		}
		request.url = validURL
	}
}
