//
//  GamesCacheDataSource.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Foundation

protocol GamesCacheDataSource {
	func storeGamesCache(input: GamesInput, output: GamesOutput) async
	func getGamesCache(input: GamesInput) async -> GamesOutput?
}

struct GamesCacheDataSourceImpl: GamesCacheDataSource {

	private let gamesCache: TTLCache<GamesInput, GamesOutput>

	init() {
		self.gamesCache = .init(timeToLive: .seconds(60 * 5))
	}

	func storeGamesCache(input: GamesInput, output: GamesOutput) async {
		await self.gamesCache.store(output, forKey: input)
	}

	func getGamesCache(input: GamesInput) async -> GamesOutput? {
		await self.gamesCache.value(forKey: input)
	}
}
