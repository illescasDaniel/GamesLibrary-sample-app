import BetterLogger
import GamesLibraryCore

struct GamesRepository: GamesRepositoryPort, Sendable {
	let cacheDataSource: any GamesCacheDataSource
	let networkDataSource: any GamesNetworkDataSource
	let logger: BetterLogger

	func searchGames(query: String, page: Int, pageSize: Int, ordering: String?) async throws -> [GameSummary] {
		let input = GamesInputDTO(
			page: page,
			pageSize: pageSize,
			search: query.isEmpty ? nil : query,
			searchPrecise: true,
			searchExact: true,
			parentPlatforms: nil,
			platforms: nil,
			stores: nil,
			developers: nil,
			publishers: nil,
			genres: nil,
			tags: nil,
			creators: nil,
			dates: nil,
			updated: nil,
			platformsCount: nil,
			metacritic: nil,
			excludeCollection: nil,
			excludeAdditions: nil,
			excludeParents: nil,
			excludeGameSeries: nil,
			excludeStores: nil,
			ordering: ordering
		)

		if let cached = await cacheDataSource.loadGamesCache(input: input) {
			logger.debug("Returning cached data")
			return GameSearchItemDTOMapper.toDomainList(cached.results)
		}

		let output = try await networkDataSource.games(input)
		await cacheDataSource.saveGamesCache(input: input, output: output)
		return GameSearchItemDTOMapper.toDomainList(output.results)
	}

	func gameDetails(id: GameID) async throws -> GameDetails {
		if let cached = await cacheDataSource.loadGameCache(id: id.rawValue) {
			logger.debug("Returning cached data")
			guard let details = GameDTOMapper.toDomain(cached) else {
				throw GamesError.notFound
			}
			return details
		}

		let dto = try await networkDataSource.game(id: id.rawValue)
		await cacheDataSource.saveGameCache(id: id.rawValue, output: dto)
		guard let details = GameDTOMapper.toDomain(dto) else {
			throw GamesError.notFound
		}
		return details
	}
}
