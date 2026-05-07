import Foundation
@testable import GamesLibrary
import BetterLogger
import HTTIES

enum MockError: Error {
	case notConfigured
}

final class MockGamesRepository: GamesRepository, @unchecked Sendable {
	var gamesResult: Result<GamesOutput, any Error>?
	var gameResult: Result<Game, any Error>?

	func games(_ input: GamesInput) async throws -> GamesOutput {
		if let gamesResult {
			return try gamesResult.get()
		}
		throw MockError.notConfigured
	}

	func game(id: Int) async throws -> Game {
		if let gameResult {
			return try gameResult.get()
		}
		throw MockError.notConfigured
	}
}

@MainActor
class MockGetListOfGames: GetListOfGames {
	var result: Result<[GameSearchItem], any Error>?
	var lastPage: Int?

	func callAsFunction(page: Int) async throws -> [GameSearchItem] {
		lastPage = page
		if let result {
			return try result.get()
		}
		throw MockError.notConfigured
	}
}

@MainActor
class MockSearchGame: SearchGame {
	var result: Result<[GameSearchItem], any Error>?
	var lastPage: Int?
	var lastSearchText: String?

	func callAsFunction(page: Int, searchText: String) async throws -> [GameSearchItem] {
		lastPage = page
		lastSearchText = searchText
		if let result {
			return try result.get()
		}
		throw MockError.notConfigured
	}
}

@MainActor
class MockGetGameDetails: GetGameDetails {
	var result: Result<Game, any Error>?
	var lastId: Int?

	func callAsFunction(id: Int) async throws -> Game {
		lastId = id
		if let result {
			return try result.get()
		}
		throw MockError.notConfigured
	}
}

final class MockGamesCacheDataSource: GamesCacheDataSource, @unchecked Sendable {
	var savedGames: [GamesInput: GamesOutput] = [:]
	var savedGameDetails: [Int: Game] = [:]

	func saveGamesCache(input: GamesInput, output: GamesOutput) async {
		savedGames[input] = output
	}

	func loadGamesCache(input: GamesInput) async -> GamesOutput? {
		savedGames[input]
	}

	func saveGameCache(id: Int, output: Game) async {
		savedGameDetails[id] = output
	}

	func loadGameCache(id: Int) async -> Game? {
		savedGameDetails[id]
	}
}

final class MockGamesNetworkDataSource: GamesNetworkDataSource, @unchecked Sendable {
	var gamesResult: Result<GamesOutput, any Error>?
	var gameResult: Result<Game, any Error>?

	func games(_ input: GamesInput) async throws -> GamesOutput {
		if let gamesResult {
			return try gamesResult.get()
		}
		throw MockError.notConfigured
	}

	func game(id: Int) async throws -> Game {
		if let gameResult {
			return try gameResult.get()
		}
		throw MockError.notConfigured
	}
}

final class MockHTTPClient: HTTPClient, @unchecked Sendable {
	var result: Any?
	var lastRequest: HTTPURLRequest?

	func sendRequest(_ httpURLRequest: HTTPURLRequest) async throws -> (Data, HTTPURLResponse) {
		lastRequest = httpURLRequest
		throw MockError.notConfigured
	}

	func sendRequest<T: Decodable>(
		_ httpURLRequest: HTTPURLRequest,
		decoding: T.Type,
		decoder: any DecodableDecoder
	) async throws -> T {
		lastRequest = httpURLRequest
		if let result = result as? T {
			return result
		}
		throw MockError.notConfigured
	}
}

extension Game {
	@MainActor
	static func dummy(id: Int = 1) -> Game {
		let data = Data(#"{ "id": \#(id), "name": "Test Game", "rating": 4.5 }"#.utf8)
		return try! JSONDecoder().decode(Game.self, from: data)
	}
}

extension GameSearchItem {
	@MainActor
	static func dummy(id: Int = 1, name: String = "Test Game") -> GameSearchItem {
		let data = Data(#"{ "id": \#(id), "name": "\#(name)", "rating": 4.5 }"#.utf8)
		return try! JSONDecoder().decode(GameSearchItem.self, from: data)
	}
}

extension GamesOutput {
	@MainActor
	static func dummy(results: [GameSearchItem]) -> GamesOutput {
		let resultsJson = results.map {
			#"{ "id": \#($0.id ?? 0), "name": "\#($0.name ?? "")", "rating": \#($0.rating ?? 0.0) }"#
		}.joined(separator: ",")
		let data = Data(#"{ "count": \#(results.count), "results": [\#(resultsJson)] }"#.utf8)
		return try! JSONDecoder().decode(GamesOutput.self, from: data)
	}
}

extension GamesInput {
	@MainActor
	static func dummy(page: Int, pageSize: Int) -> GamesInput {
		GamesInput(page: page, pageSize: pageSize, search: nil, searchPrecise: nil, searchExact: nil, parentPlatforms: nil, platforms: nil, stores: nil, developers: nil, publishers: nil, genres: nil, tags: nil, creators: nil, dates: nil, updated: nil, platformsCount: nil, metacritic: nil, excludeCollection: nil, excludeAdditions: nil, excludeParents: nil, excludeGameSeries: nil, excludeStores: nil, ordering: nil)
	}
}
