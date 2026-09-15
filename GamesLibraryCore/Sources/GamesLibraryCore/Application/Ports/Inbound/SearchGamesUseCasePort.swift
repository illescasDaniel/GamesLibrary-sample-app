public protocol SearchGamesUseCasePort: Sendable {
	func callAsFunction(page: Int, searchText: String) async throws -> [GameSummary]
}
