//
//  SearchGame.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

protocol SearchGame {
	func callAsFunction(page: Int, searchText: String) async throws -> [Game]
}

struct SearchGameImpl: SearchGame {

	let gamesRepository: any GamesRepository
	let pageSize: Int = 20

	func callAsFunction(page: Int, searchText: String) async throws -> [Game] {
		let input = GamesInput(
			page: page,
			pageSize: pageSize,
			search: searchText,
			searchPrecise: nil, searchExact: nil, parentPlatforms: nil, platforms: nil, stores: nil, developers: nil, publishers: nil, genres: nil, tags: nil, creators: nil, dates: nil, updated: nil, platformsCount: nil, metacritic: nil, excludeCollection: nil, excludeAdditions: nil, excludeParents: nil, excludeGameSeries: nil, excludeStores: nil,
			ordering: nil
		)
		let output = try await gamesRepository.games(input)
		return output.results
	}
}
