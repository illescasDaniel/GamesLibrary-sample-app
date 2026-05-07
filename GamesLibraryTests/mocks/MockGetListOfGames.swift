import Foundation
@testable import GamesLibrary

@MainActor
final class MockGetListOfGames: GetListOfGames {
	var result: Result<[GameSearchItem], any Error>?
	var lastPage: Int?

	func callAsFunction(page: Int) async throws -> [GameSearchItem] {
		lastPage = page
		if let result {
			return try result.get()
		}
		throw MockError.notConfigured
	}
}
