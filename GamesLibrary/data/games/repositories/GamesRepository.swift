//
//  GamesRepository.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import BetterLogger

protocol GamesRepository {
	func games(_ input: GamesInput) async throws -> GamesOutput
	func game(id: Int) async throws -> Game
}

struct GamesRepositoryImpl: GamesRepository {

	let cacheDataSource: any GamesCacheDataSource
	let networkDataSource: any GamesNetworkDataSource
	let logger: BetterLogger

	func games(_ input: GamesInput) async throws -> GamesOutput {
		if let cachedData = await cacheDataSource.loadGamesCache(input: input) {
			logger.debug("Returning cached data")
			return cachedData
		}
		let output = try await networkDataSource.games(input)
		await cacheDataSource.saveGamesCache(input: input, output: output)
		return output
	}

	func game(id: Int) async throws -> Game {
		if let cachedData = await cacheDataSource.loadGameCache(id: id) {
			logger.debug("Returning cached data")
			return cachedData
		}
		let output = try await networkDataSource.game(id: id)
		await cacheDataSource.saveGameCache(id: id, output: output)
		return output
	}
}
