import Foundation
@testable import GamesLibrary

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
