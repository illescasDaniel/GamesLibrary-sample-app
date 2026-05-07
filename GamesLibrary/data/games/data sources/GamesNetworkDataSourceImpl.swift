//
//  GamesNetworkDataSourceImpl.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import HTTIES
import Foundation

protocol GamesNetworkDataSource {
	func games(_ input: GamesInput) async throws -> GamesOutput
}

struct GamesNetworkDataSourceImpl: GamesNetworkDataSource {

	let httpClient: any HTTPClient
	let environment: Environment
	let jsonDecoder: JSONDecoder

	func games(_ input: GamesInput) async throws -> GamesOutput {
		let request: HTTPURLRequest = try HTTPURLRequest(
			url: environment.baseURL / "games",
			httpMethod: .get,
			queryItems: input.queryItems
		)
		let gamesOutput = try await httpClient.sendRequest(
			request,
			decoding: GamesOutput.self,
			decoder: jsonDecoder
		)
		return gamesOutput
	}
}
