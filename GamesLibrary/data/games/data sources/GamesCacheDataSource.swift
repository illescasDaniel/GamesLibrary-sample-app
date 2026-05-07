//
//  GamesCacheDataSource.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Foundation

protocol GamesCacheDataSource {
	func saveGamesCache(input: GamesInput, output: GamesOutput) async
	func loadGamesCache(input: GamesInput) async -> GamesOutput?
	func saveGameCache(id: Int, output: Game) async
	func loadGameCache(id: Int) async -> Game?
}

struct GamesCacheDataSourceImpl: GamesCacheDataSource {

	private let gamesCache: TTLCache<GamesInput, GamesOutput>
	private let gameCache: TTLCache<Int, Game>

	init(timeToLive: Duration) {
		self.gamesCache = .init(timeToLive: timeToLive)
		self.gameCache = .init(timeToLive: timeToLive)
	}

	func saveGamesCache(input: GamesInput, output: GamesOutput) async {
		await self.gamesCache.store(output, forKey: input)
	}

	func loadGamesCache(input: GamesInput) async -> GamesOutput? {
		await self.gamesCache.value(forKey: input)
	}

	func saveGameCache(id: Int, output: Game) async {
		await self.gameCache.store(output, forKey: id)
	}

	func loadGameCache(id: Int) async -> Game? {
		await self.gameCache.value(forKey: id)
	}
}
