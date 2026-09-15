import Testing
import Foundation
import GamesLibraryCore
@testable import GamesLibrary
import BetterLogger

@Suite
@MainActor
struct GamesRepositoryTests {

    @Test
    func givenRepositoryWhenFetchingGamesAndCacheExistsThenReturnsCachedGames() async throws {
        let mockCache = MockGamesCacheDataSource()
        let mockNetwork = MockGamesNetworkDataSource()
        let repository = GamesRepository(
            cacheDataSource: mockCache,
            networkDataSource: mockNetwork,
            logger: BetterLogger(name: "Test")
        )

        let input = GamesInputDTO.dummy(page: 1, pageSize: 20)
        let cachedOutput = GamesOutputDTO.dummy(results: [GameSearchItemDTO.dummy(id: 1)])
        await mockCache.saveGamesCache(input: input, output: cachedOutput)

        let result = try await repository.searchGames(query: "", page: 1, pageSize: 20, ordering: nil)

        #expect(result.first?.id == GameID(1))
        #expect(mockNetwork.gamesResult == nil)
    }

    @Test
    func givenRepositoryWhenFetchingGamesAndCacheIsEmptyThenFetchesFromNetworkAndSavesToCache() async throws {
        let mockCache = MockGamesCacheDataSource()
        let mockNetwork = MockGamesNetworkDataSource()
        let repository = GamesRepository(
            cacheDataSource: mockCache,
            networkDataSource: mockNetwork,
            logger: BetterLogger(name: "Test")
        )

        mockNetwork.gamesResult = .success(GamesOutputDTO.dummy(results: [GameSearchItemDTO.dummy(id: 2)]))

        let result = try await repository.searchGames(query: "Test", page: 1, pageSize: 20, ordering: "-added")

        #expect(result.first?.id == GameID(2))
        let cacheInput = GamesInputDTO(
            page: 1, pageSize: 20, search: "Test",
            searchPrecise: true, searchExact: true,
            parentPlatforms: nil, platforms: nil, stores: nil,
            developers: nil, publishers: nil, genres: nil, tags: nil,
            creators: nil, dates: nil, updated: nil, platformsCount: nil,
            metacritic: nil, excludeCollection: nil, excludeAdditions: nil,
            excludeParents: nil, excludeGameSeries: nil, excludeStores: nil,
            ordering: "-added"
        )
        #expect(await mockCache.loadGamesCache(input: cacheInput)?.results.first?.id == 2)
    }

    @Test
    func givenRepositoryWhenFetchingGamesFailsThenThrowsError() async throws {
        let mockCache = MockGamesCacheDataSource()
        let mockNetwork = MockGamesNetworkDataSource()
        let repository = GamesRepository(
            cacheDataSource: mockCache,
            networkDataSource: mockNetwork,
            logger: BetterLogger(name: "Test")
        )
        mockNetwork.gamesResult = .failure(MockError.anyError)

        await #expect(throws: MockError.anyError) {
            try await repository.searchGames(query: "Test", page: 1, pageSize: 20, ordering: nil)
        }
    }

    @Test
    func givenRepositoryWhenFetchingGameDetailAndCacheExistsThenReturnsCachedGame() async throws {
        let mockCache = MockGamesCacheDataSource()
        let mockNetwork = MockGamesNetworkDataSource()
        let repository = GamesRepository(
            cacheDataSource: mockCache,
            networkDataSource: mockNetwork,
            logger: BetterLogger(name: "Test")
        )

        let gameId = 123
        await mockCache.saveGameCache(id: gameId, output: GameDTO.dummy(id: gameId))

        let result = try await repository.gameDetails(id: GameID(gameId))

        #expect(result.id == GameID(gameId))
        #expect(mockNetwork.gameResult == nil)
    }

    @Test
    func givenRepositoryWhenFetchingGameDetailAndCacheIsEmptyThenFetchesFromNetwork() async throws {
        let mockCache = MockGamesCacheDataSource()
        let mockNetwork = MockGamesNetworkDataSource()
        let repository = GamesRepository(
            cacheDataSource: mockCache,
            networkDataSource: mockNetwork,
            logger: BetterLogger(name: "Test")
        )

        let gameId = 456
        mockNetwork.gameResult = .success(GameDTO.dummy(id: gameId))

        let result = try await repository.gameDetails(id: GameID(gameId))

        #expect(result.id == GameID(gameId))
        #expect(await mockCache.loadGameCache(id: gameId)?.id == gameId)
    }

    @Test
    func givenRepositoryWhenGameDTOHasNoIdThenThrowsNotFound() async throws {
        let mockCache = MockGamesCacheDataSource()
        let mockNetwork = MockGamesNetworkDataSource()
        let repository = GamesRepository(
            cacheDataSource: mockCache,
            networkDataSource: mockNetwork,
            logger: BetterLogger(name: "Test")
        )

        let json = #"{"name": "No ID"}"#
        let dto = try JSONDecoder().decode(GameDTO.self, from: Data(json.utf8))
        mockNetwork.gameResult = .success(dto)

        await #expect(throws: GamesError.notFound) {
            try await repository.gameDetails(id: GameID(1))
        }
    }

    @Test
    func givenRepositoryWhenSearchResultsIncludeNilIdDTOsThenTheyAreFiltered() async throws {
        let mockCache = MockGamesCacheDataSource()
        let mockNetwork = MockGamesNetworkDataSource()
        let repository = GamesRepository(
            cacheDataSource: mockCache,
            networkDataSource: mockNetwork,
            logger: BetterLogger(name: "Test")
        )

        let validItem = GameSearchItemDTO.dummy(id: 1)
        let json = #"{"name": "No ID"}"#
        let invalidItem = try JSONDecoder().decode(GameSearchItemDTO.self, from: Data(json.utf8))
        mockNetwork.gamesResult = .success(GamesOutputDTO.dummy(results: [validItem, invalidItem]))

        let result = try await repository.searchGames(query: "", page: 1, pageSize: 20, ordering: nil)

        #expect(result.count == 1)
        #expect(result.first?.id == GameID(1))
    }
}
