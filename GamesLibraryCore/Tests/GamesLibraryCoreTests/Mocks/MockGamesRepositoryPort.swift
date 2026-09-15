import Foundation
@testable import GamesLibraryCore

final class MockGamesRepositoryPort: GamesRepositoryPort, @unchecked Sendable {
	var searchResult: Result<[GameSummary], any Error>?
	var detailsResult: Result<GameDetails, any Error>?
	var lastSearchQuery: String?
	var lastSearchPage: Int?
	var lastSearchPageSize: Int?
	var lastSearchOrdering: String?
	var lastDetailsID: GameID?

	func searchGames(query: String, page: Int, pageSize: Int, ordering: String?) async throws -> [GameSummary] {
		lastSearchQuery = query
		lastSearchPage = page
		lastSearchPageSize = pageSize
		lastSearchOrdering = ordering
		if let searchResult {
			return try searchResult.get()
		}
		throw MockCoreError.notConfigured
	}

	func gameDetails(id: GameID) async throws -> GameDetails {
		lastDetailsID = id
		if let detailsResult {
			return try detailsResult.get()
		}
		throw MockCoreError.notConfigured
	}
}

enum MockCoreError: Error {
	case notConfigured
}
