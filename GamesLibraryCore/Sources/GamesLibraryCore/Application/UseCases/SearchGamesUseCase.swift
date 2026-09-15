public struct SearchGamesUseCase: SearchGamesUseCasePort, Sendable {
    private let repository: any GamesRepositoryPort
    private let pageSize: Int

    public init(repository: any GamesRepositoryPort, pageSize: Int = 20) {
        self.repository = repository
        self.pageSize = pageSize
    }

    public func callAsFunction(page: Int, searchText: String) async throws -> [GameSummary] {
        let ordering = searchText.isEmpty ? nil : "-added"
        return try await repository.searchGames(
            query: searchText,
            page: page,
            pageSize: pageSize,
            ordering: ordering
        )
    }
}
