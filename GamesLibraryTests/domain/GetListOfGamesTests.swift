import Testing
import Foundation
@testable import GamesLibrary

@Suite
@MainActor
struct GetListOfGamesTests {

	@Test
	func givenUseCaseWhenExecutedSucceedsThenResultIsCorrect() async throws {
		// given
		let mockRepository = MockGamesRepository()
		let useCase = GetListOfGamesImpl(gamesRepository: mockRepository)

		let expectedGames = [GameSearchItem.dummy(id: 1)]
		mockRepository.gamesResult = .success(GamesOutput.dummy(results: expectedGames))

		// when
		let result = try await useCase(page: 1)

		// then
		#expect(result.count == 1)
		#expect(result.first?.id == 1)
	}
}
