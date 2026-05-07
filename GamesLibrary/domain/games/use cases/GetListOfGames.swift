//
//  GetListOfGames.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

protocol GetListOfGames {
	func callAsFunction(page: Int) async throws -> [Game]
}

struct GetListOfGamesImpl: GetListOfGames {

	let gamesRepository: any GamesRepository
	let pageSize: Int = 50

	func callAsFunction(page: Int) async throws -> [Game] {
		let input = GamesInput(
			page: page,
			pageSize: pageSize,
			search: nil, searchPrecise: nil, searchExact: nil, parentPlatforms: nil, platforms: nil, stores: nil, developers: nil, publishers: nil, genres: nil, tags: nil, creators: nil, dates: nil, updated: nil, platformsCount: nil, metacritic: nil, excludeCollection: nil, excludeAdditions: nil, excludeParents: nil, excludeGameSeries: nil, excludeStores: nil,
			ordering: "released"
		)
		let output = try await gamesRepository.games(input)
		return output.results
	}
}
