import Testing
import Foundation
@testable import GamesLibrary

@Suite
@MainActor
struct GetGameDetailsTests {

	@Test("Execute use case successfully")
	func givenUseCaseWhenExecutedSucceedsThenResultIsCorrect() async throws {
		// given
		let mockRepository = MockGamesRepository()
		let useCase = GetGameDetailsImpl(gamesRepository: mockRepository)

		let expectedGame = Game.dummy(id: 123)
		mockRepository.gameResult = .success(expectedGame)

		// when
		let result = try await useCase(id: 123)

		// then
		#expect(result.id == 123)
	}

	@Test
	func givenUseCaseWhenExecutedFailsThenThrowsError() async throws {
		// given
		let mockRepository = MockGamesRepository()
		let useCase = GetGameDetailsImpl(gamesRepository: mockRepository)

		mockRepository.gameResult = .failure(MockError.anyError)

		// when / then
		await #expect(throws: MockError.anyError) {
			try await useCase(id: 123)
		}
	}
}
