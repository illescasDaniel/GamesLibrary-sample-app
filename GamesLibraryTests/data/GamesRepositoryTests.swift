import Testing
import Foundation
@testable import GamesLibrary
import BetterLogger

@Suite
@MainActor
struct GamesRepositoryTests {

	@Test
	func givenRepositoryWhenFetchingGamesAndCacheExistsThenReturnsCachedGames() async throws {
		// given
		let mockCache = MockGamesCacheDataSource()
		let mockNetwork = MockGamesNetworkDataSource()
		let repository = GamesRepositoryImpl(
			cacheDataSource: mockCache,
			networkDataSource: mockNetwork,
			logger: BetterLogger(name: "Test")
		)

		let input = GamesInput.dummy(page: 1, pageSize: 20)
		let cachedOutput = GamesOutput.dummy(results: [GameSearchItem.dummy(id: 1)])
		await mockCache.saveGamesCache(input: input, output: cachedOutput)

		// when
		let result = try await repository.games(input)

		// then
		#expect(result.results.first?.id == 1)
		#expect(mockNetwork.gamesResult == nil) // Network should not be called
	}

	@Test
	func givenRepositoryWhenFetchingGamesAndCacheIsEmptyThenFetchesFromNetworkAndSavesToCache() async throws {
		// given
		let mockCache = MockGamesCacheDataSource()
		let mockNetwork = MockGamesNetworkDataSource()
		let repository = GamesRepositoryImpl(
			cacheDataSource: mockCache,
			networkDataSource: mockNetwork,
			logger: BetterLogger(name: "none")
		)

		let input = GamesInput.dummy(page: 1, pageSize: 20)
		let networkOutput = GamesOutput.dummy(results: [GameSearchItem.dummy(id: 2)])
		mockNetwork.gamesResult = .success(networkOutput)

		// when
		let result = try await repository.games(input)

		// then
		#expect(result.results.first?.id == 2)
		#expect(await mockCache.loadGamesCache(input: input)?.results.first?.id == 2)
	}
}
