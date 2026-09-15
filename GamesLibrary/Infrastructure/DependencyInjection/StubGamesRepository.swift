#if DEBUG
import Foundation
import GamesLibraryCore

/// Deterministic outbound stub for UI tests. Activated via `-UITesting` launch argument.
struct StubGamesRepository: GamesRepositoryPort, Sendable {
    func searchGames(query: String, page: Int, pageSize: Int, ordering: String?) async throws -> [GameSummary] {
        if UITestSupport.shouldForceEmptyResults || query.contains("zzzznonexistent") {
            return []
        }
        if page > 1 {
            return []
        }
        return [
            GameSummary(id: GameID(1), name: "Stub Game One", rating: 4.5, released: "2024-01-01"),
            GameSummary(id: GameID(2), name: "Stub Game Two", rating: 4.0, released: "2023-06-15"),
        ]
    }

    func gameDetails(id: GameID) async throws -> GameDetails {
        GameDetails(
            summary: GameSummary(
                id: id,
                name: "Stub Game \(id.rawValue)",
                rating: 4.5,
                released: "2024-01-01"
            ),
            descriptionRaw: "Stub description for UI testing."
        )
    }
}
#endif
