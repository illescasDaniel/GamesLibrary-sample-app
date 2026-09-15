import HTTIES
import Foundation

protocol GamesNetworkDataSource: Sendable {
	func games(_ input: GamesInputDTO) async throws -> GamesOutputDTO
	func game(id: Int) async throws -> GameDTO
}

struct GamesNetworkDataSourceImpl: GamesNetworkDataSource {
	let httpClient: any HTTPClient
	let environment: AppEnvironment
	let jsonDecoder: JSONDecoder

	func games(_ input: GamesInputDTO) async throws -> GamesOutputDTO {
		let request: HTTPURLRequest = try HTTPURLRequest(
			url: environment.baseURL / "games",
			httpMethod: .get,
			queryItems: input.queryItems
		)
		do {
			return try await httpClient.sendRequest(
				request,
				decoding: GamesOutputDTO.self,
				decoder: jsonDecoder
			)
		} catch let error as AppNetworkResponseError {
			if case .unexpected(statusCode: 404) = error {
				return GamesOutputDTO(count: 0, next: nil, previous: nil, results: [])
			}
			throw error
		}
	}

	func game(id: Int) async throws -> GameDTO {
		let request: HTTPURLRequest = try HTTPURLRequest(
			url: environment.baseURL / "games" / id,
			httpMethod: .get
		)
		return try await httpClient.sendRequest(
			request,
			decoding: GameDTO.self,
			decoder: jsonDecoder
		)
	}
}
