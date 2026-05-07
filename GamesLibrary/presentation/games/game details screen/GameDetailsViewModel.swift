//
//  GameDetailsViewModel.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Observation
import Foundation
import BetterLogger

@Observable
final class GameDetailsViewModel {

	var gamesState: ViewState<Game, any Error> = .loading

	private let getGameDetails: any GetGameDetails
	private let logger: BetterLogger

	init(getGameDetails: any GetGameDetails, logger: BetterLogger) {
		self.getGameDetails = getGameDetails
		self.logger = logger
	}

	func getGameDetails(id: Int) async {
		gamesState = .loading
		do {
			let game = try await self.getGameDetails(id: id)
			gamesState = .success(game)
		} catch {
			logger.error("Get game details failed", context: ["error": error])
			gamesState = .error(error)
		}
	}
}
