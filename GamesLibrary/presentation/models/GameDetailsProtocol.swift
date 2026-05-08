//
//  GameDetails.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 8/5/26.
//

import Foundation
protocol GameDetailsProtocol {
	var rating: Double? { get }
	var esrbRating: ESRBRating? { get }
	var released: String? { get }
	var playtime: Int? { get }
	var validDescription: String? { get }
	var backgroundImage: String? { get }
	var website: String? { get }
	var platforms: [PlatformEntry]? { get }
}

extension Game: GameDetailsProtocol {
	var validDescription: String? {
		if let rawDescription = rawDescription?.trimmingCharacters(in: .whitespacesAndNewlines), !rawDescription.isEmpty {
			return rawDescription
		}
		return description?.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
extension GameSearchItem: GameDetailsProtocol {
	var validDescription: String? {
		nil
	}
	var website: String? {
		nil
	}
}
