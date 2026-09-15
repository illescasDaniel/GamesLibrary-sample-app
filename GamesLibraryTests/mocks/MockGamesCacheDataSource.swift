import Foundation
@testable import GamesLibrary

final class MockGamesCacheDataSource: GamesCacheDataSource, @unchecked Sendable {
    private var gamesCache: [GamesInputDTO: GamesOutputDTO] = [:]
    private var gameCache: [Int: GameDTO] = [:]

    func saveGamesCache(input: GamesInputDTO, output: GamesOutputDTO) async {
        gamesCache[input] = output
    }

    func loadGamesCache(input: GamesInputDTO) async -> GamesOutputDTO? {
        gamesCache[input]
    }

    func saveGameCache(id: Int, output: GameDTO) async {
        gameCache[id] = output
    }

    func loadGameCache(id: Int) async -> GameDTO? {
        gameCache[id]
    }
}
