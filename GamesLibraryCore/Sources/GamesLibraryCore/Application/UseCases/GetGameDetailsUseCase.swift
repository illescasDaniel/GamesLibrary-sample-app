public struct GetGameDetailsUseCase: GetGameDetailsUseCasePort, Sendable {
    private let repository: any GamesRepositoryPort

    public init(repository: any GamesRepositoryPort) {
        self.repository = repository
    }

    public func callAsFunction(id: GameID) async throws -> GameDetails {
        try await repository.gameDetails(id: id)
    }
}
