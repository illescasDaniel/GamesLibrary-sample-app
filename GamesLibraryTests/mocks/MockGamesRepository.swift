import Foundation
@testable import GamesLibrary

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
