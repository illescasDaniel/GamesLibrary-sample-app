//
//  GamesRepository.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

protocol GamesRepository {
	func games(_ input: GamesInput) async throws -> GamesOutput
}

struct GamesRepositoryImpl: GamesRepository {

	let cacheDataSource: any GamesCacheDataSource
	let networkDataSource: any GamesNetworkDataSource

	func games(_ input: GamesInput) async throws -> GamesOutput {
		if let cachedData = await cacheDataSource.getGamesCache(input: input) {
			return cachedData
		}
		let output = try await networkDataSource.games(input)
		await cacheDataSource.storeGamesCache(input: input, output: output)
		return output
	}
}
