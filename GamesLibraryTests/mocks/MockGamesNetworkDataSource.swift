import Foundation
@testable import GamesLibrary

final class MockGamesNetworkDataSource: GamesNetworkDataSource, @unchecked Sendable {
    var gamesResult: Result<GamesOutputDTO, any Error>?
    var gameResult: Result<GameDTO, any Error>?

    func games(_ input: GamesInputDTO) async throws -> GamesOutputDTO {
        if let gamesResult {
            return try gamesResult.get()
        }
        throw MockError.notConfigured
    }

    func game(id: Int) async throws -> GameDTO {
        if let gameResult {
            return try gameResult.get()
        }
        throw MockError.notConfigured
    }
}
