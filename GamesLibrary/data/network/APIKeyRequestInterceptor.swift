//
//  APIKeyRequestInterceptor.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import HTTIES
import Foundation

struct APIKeyRequestInterceptor: HTTPInoutRequestInterceptor {

	let apiKey: String

	init(apiKey: String) {
		self.apiKey = apiKey
	}

	func intercept(request: inout URLRequest) {
		guard
			let url = request.url?.absoluteString,
			var urlComponents = URLComponents(string: url)
		else {
			// TODO: logger
			return
		}
		
		urlComponents.queryItems = (urlComponents.queryItems ?? []) + [
			URLQueryItem(name: "key", value: apiKey)
		]

		guard let validURL = urlComponents.url else {
			// TODO: logger
			return
		}
		request.url = validURL
	}
}
