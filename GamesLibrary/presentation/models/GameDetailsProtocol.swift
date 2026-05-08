//
//  GameDetails.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 8/5/26.
//

protocol GameDetailsProtocol {
	var rating: Double? { get }
	var esrbRating: ESRBRating? { get }
	var released: String? { get }
	var playtime: Int? { get }
	var description: String? { get }
	var backgroundImage: String? { get }
	var website: String? { get }
	var platforms: [PlatformEntry]? { get }
}

extension Game: GameDetailsProtocol {}
extension GameSearchItem: GameDetailsProtocol {
	var description: String? {
		nil
	}
	var website: String? {
		nil
	}
}
