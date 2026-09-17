import Testing
@testable import GamesLibraryCore

@Suite
struct SearchGamesUseCaseTests {

	@Test
	func `Given Use Case When Executed Succeeds Then Result Is Correct`() async throws {
		let mockRepository = MockGamesRepositoryPort()
		let useCase = SearchGamesUseCase(repository: mockRepository)

		let expected = [GameSummary(id: GameID(2), name: "Test")]
		mockRepository.searchResult = .success(expected)

		let result = try await useCase(page: 1, searchText: "Test")

		#expect(result.count == 1)
		#expect(result.first?.id == GameID(2))
		#expect(mockRepository.lastSearchOrdering == "-added")
	}

	@Test
	func `Given Use Case When Search Text Empty Then Ordering Is Nil`() async throws {
		let mockRepository = MockGamesRepositoryPort()
		let useCase = SearchGamesUseCase(repository: mockRepository)
		mockRepository.searchResult = .success([])

		_ = try await useCase(page: 1, searchText: "")

		#expect(mockRepository.lastSearchOrdering == nil)
	}

	@Test
	func `Given Use Case When Executed Fails Then Throws Error`() async throws {
		let mockRepository = MockGamesRepositoryPort()
		let useCase = SearchGamesUseCase(repository: mockRepository)
		mockRepository.searchResult = .failure(MockCoreError.notConfigured)

		await #expect(throws: MockCoreError.notConfigured) {
			try await useCase(page: 1, searchText: "Test")
		}
	}

	@Test
	func `Given Use Case When Executed Then Passes Page Size To Repository`() async throws {
		let mockRepository = MockGamesRepositoryPort()
		let useCase = SearchGamesUseCase(repository: mockRepository, pageSize: 10)
		mockRepository.searchResult = .success([])

		_ = try await useCase(page: 2, searchText: "Test")

		#expect(mockRepository.lastSearchPageSize == 10)
		#expect(mockRepository.lastSearchPage == 2)
	}
}
