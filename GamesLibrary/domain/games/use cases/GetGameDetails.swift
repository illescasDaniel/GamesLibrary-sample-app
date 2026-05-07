//
//  GetGameDetails.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 7/5/26.
//

protocol GetGameDetails {
	func callAsFunction(id: Int) async throws -> Game
}

struct GetGameDetailsImpl: GetGameDetails {

	let gamesRepository: any GamesRepository

	func callAsFunction(id: Int) async throws -> Game {
		try await gamesRepository.game(id: id)
	}
}
