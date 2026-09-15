public protocol GamesRepositoryPort: Sendable {
    func searchGames(query: String, page: Int, pageSize: Int, ordering: String?) async throws -> [GameSummary]
    func gameDetails(id: GameID) async throws -> GameDetails
}
