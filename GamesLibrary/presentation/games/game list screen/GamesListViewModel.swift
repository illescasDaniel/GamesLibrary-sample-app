//
//  GamesListViewModel.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Observation
import Foundation
import BetterLogger

@Observable
final class GamesListViewModel {

	var gamesState: ViewState<[GameSearchItem], any Error> = .loading
	var currentPage: Int = 1
	var searchText: String = ""
	var gamesTask: Task<Void, Never>?

	private let getListOfGames: any GetListOfGames
	private let searchGame: any SearchGame
	private let logger: BetterLogger

	init(getListOfGames: any GetListOfGames, searchGame: any SearchGame, logger: BetterLogger) {
		self.getListOfGames = getListOfGames
		self.searchGame = searchGame
		self.logger = logger
	}

	func getGames() async {
		gamesTask?.cancel()
		gamesState = .loading

		gamesTask = Task {
			do {
				let games = try await self.getListOfGames(page: currentPage)
				if gamesTask?.isCancelled == true {
					logger.debug("Get games cancelled")
					return
				}
				gamesState = .success(games)
			} catch {
				logger.error("Get list of games failed", context: ["error": error])
				if gamesTask?.isCancelled == true {
					logger.debug("Get games cancelled")
					return
				}
				gamesState = .error(error)
			}
		}

		await gamesTask?.value
	}

	func searchGame(oldSearchText: String?, newSearchText: String) {
		let cleanSearchText = newSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
		if oldSearchText == cleanSearchText {
			logger.debug("Old search text is equivalent to the new one, not performing a new search")
			return
		}
		if cleanSearchText.isEmpty {
			Task { await getGames() }
			logger.debug("Search text is empty, not performing a new search, reverting to the list")
			return
		}

		gamesTask?.cancel()
		gamesState = .loading

		gamesTask = Task {
			do {
				try await Task.sleep(for: .milliseconds(150))
				await _searchGame(newSearchText)
			} catch {
				logger.debug("Search cancelled due to throttling")
			}
		}
	}

	private func _searchGame(_ searchText: String) async {
		gamesState = .loading
		do {
			let games = try await self.searchGame(page: currentPage, searchText: searchText)
			if gamesTask?.isCancelled == true {
				logger.debug("Search cancelled due to newer search")
				return
			}
			gamesState = .success(games)
		} catch {
			logger.error("Search failed", context: ["error": error])
			if gamesTask?.isCancelled == true {
				logger.debug("Search cancelled due to newer search")
				return
			}
			if (error as NSError).code == URLError.cancelled.rawValue {
				logger.debug("Search cancelled at URL Session level")
				return
			}
			gamesState = .error(error)
		}
	}
}
