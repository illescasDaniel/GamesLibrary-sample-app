import Foundation
@testable import GamesLibrary

@MainActor
final class MockGetGameDetails: GetGameDetails {
	var result: Result<Game, any Error>?
	var lastId: Int?

	func callAsFunction(id: Int) async throws -> Game {
		lastId = id
		if let result {
			return try result.get()
		}
		throw MockError.notConfigured
	}
}
