import Testing
import Foundation
@testable import GamesLibrary

@Suite
@MainActor
struct SearchGameTests {

	@Test
	func givenUseCaseWhenExecutedSucceedsThenResultIsCorrect() async throws {
		// given
		let mockRepository = MockGamesRepository()
		let useCase = SearchGameImpl(gamesRepository: mockRepository)

		let expectedGames = [GameSearchItem.dummy(id: 2)]
		mockRepository.gamesResult = .success(GamesOutput.dummy(results: expectedGames))

		// when
		let result = try await useCase(page: 1, searchText: "Test")

		// then
		#expect(result.count == 1)
		#expect(result.first?.id == 2)
	}
}
