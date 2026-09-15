import Testing
@testable import GamesLibraryCore

@Suite
struct GetGameDetailsUseCaseTests {

    @Test
    func givenUseCaseWhenExecutedSucceedsThenResultIsCorrect() async throws {
        let mockRepository = MockGamesRepositoryPort()
        let useCase = GetGameDetailsUseCase(repository: mockRepository)

        let summary = GameSummary(id: GameID(42), name: "Game")
        let expected = GameDetails(summary: summary, descriptionRaw: "Details")
        mockRepository.detailsResult = .success(expected)

        let result = try await useCase(id: GameID(42))

        #expect(result.id == GameID(42))
        #expect(result.descriptionRaw == "Details")
    }

    @Test
    func givenUseCaseWhenExecutedFailsThenThrowsError() async throws {
        let mockRepository = MockGamesRepositoryPort()
        let useCase = GetGameDetailsUseCase(repository: mockRepository)
        mockRepository.detailsResult = .failure(MockCoreError.notConfigured)

        await #expect(throws: MockCoreError.notConfigured) {
            try await useCase(id: GameID(1))
        }
    }
}
