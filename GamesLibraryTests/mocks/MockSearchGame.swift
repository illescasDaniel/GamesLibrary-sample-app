import Foundation
@testable import GamesLibrary

@MainActor
final class MockSearchGame: SearchGame {
	var result: Result<[GameSearchItem], any Error>?
	var lastPage: Int?
	var lastSearchText: String?

	func callAsFunction(page: Int, searchText: String) async throws -> [GameSearchItem] {
		lastPage = page
		lastSearchText = searchText
		if let result {
			return try result.get()
		}
		throw MockError.notConfigured
	}
}
