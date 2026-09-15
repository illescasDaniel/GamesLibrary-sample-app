public protocol GetGameDetailsUseCasePort: Sendable {
    func callAsFunction(id: GameID) async throws -> GameDetails
}
