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

	@Test
	func givenRepositoryWhenFetchingGamesFailsThenThrowsError() async throws {
		// given
		let mockCache = MockGamesCacheDataSource()
		let mockNetwork = MockGamesNetworkDataSource()
		let repository = GamesRepositoryImpl(
			cacheDataSource: mockCache,
			networkDataSource: mockNetwork,
			logger: BetterLogger(name: "Test")
		)

		let input = GamesInput.dummy(page: 1, pageSize: 20)
		mockNetwork.gamesResult = .failure(MockError.anyError)

		// when / then
		await #expect(throws: MockError.anyError) {
			try await repository.games(input)
		}
	}

	@Test
	func givenRepositoryWhenFetchingGameDetailAndCacheExistsThenReturnsCachedGame() async throws {
		// given
		let mockCache = MockGamesCacheDataSource()
		let mockNetwork = MockGamesNetworkDataSource()
		let repository = GamesRepositoryImpl(
			cacheDataSource: mockCache,
			networkDataSource: mockNetwork,
			logger: BetterLogger(name: "Test")
		)

		let gameId = 123
		let cachedGame = Game.dummy(id: gameId)
		await mockCache.saveGameCache(id: gameId, output: cachedGame)

		// when
		let result = try await repository.game(id: gameId)

		// then
		#expect(result.id == gameId)
		#expect(mockNetwork.gameResult == nil) // Network should not be called
	}

	@Test
	func givenRepositoryWhenFetchingGameDetailAndCacheIsEmptyThenFetchesFromNetworkAndSavesToCache() async throws {
		// given
		let mockCache = MockGamesCacheDataSource()
		let mockNetwork = MockGamesNetworkDataSource()
		let repository = GamesRepositoryImpl(
			cacheDataSource: mockCache,
			networkDataSource: mockNetwork,
			logger: BetterLogger(name: "Test")
		)

		let gameId = 456
		let networkGame = Game.dummy(id: gameId)
		mockNetwork.gameResult = .success(networkGame)

		// when
		let result = try await repository.game(id: gameId)

		// then
		#expect(result.id == gameId)
		#expect(await mockCache.loadGameCache(id: gameId)?.id == gameId)
	}

	@Test
	func givenRepositoryWhenFetchingGameDetailFailsThenThrowsError() async throws {
		// given
		let mockCache = MockGamesCacheDataSource()
		let mockNetwork = MockGamesNetworkDataSource()
		let repository = GamesRepositoryImpl(
			cacheDataSource: mockCache,
			networkDataSource: mockNetwork,
			logger: BetterLogger(name: "Test")
		)

		let gameId = 789
		mockNetwork.gameResult = .failure(MockError.anyError)

		// when / then
		await #expect(throws: MockError.anyError) {
			try await repository.game(id: gameId)
		}
	}
}
