import Foundation
import GamesLibraryCore
@testable import GamesLibrary

@MainActor
final class MockSearchGamesUseCase: SearchGamesUseCasePort {
	var result: Result<[GameSummary], any Error>?
	var lastPage: Int?
	var lastSearchText: String?

	func callAsFunction(page: Int, searchText: String) async throws -> [GameSummary] {
		lastPage = page
		lastSearchText = searchText
		if let result {
			return try result.get()
		}
		throw MockError.notConfigured
	}
}
