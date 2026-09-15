import Foundation
import GamesLibraryCore
@testable import GamesLibrary

final class MockGamesRepositoryPort: GamesRepositoryPort, @unchecked Sendable {
    var searchResult: Result<[GameSummary], any Error>?
    var detailsResult: Result<GameDetails, any Error>?
    var lastSearchInput: (query: String, page: Int, pageSize: Int, ordering: String?)?

    func searchGames(query: String, page: Int, pageSize: Int, ordering: String?) async throws -> [GameSummary] {
        lastSearchInput = (query, page, pageSize, ordering)
        if let searchResult {
            return try searchResult.get()
        }
        throw MockError.notConfigured
    }

    func gameDetails(id: GameID) async throws -> GameDetails {
        if let detailsResult {
            return try detailsResult.get()
        }
        throw MockError.notConfigured
    }
}
