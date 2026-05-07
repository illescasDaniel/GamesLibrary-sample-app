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

	var games: [GameSearchItem] = []
	var gamesState: BasicViewState = .loading
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

	func getGames(oldSearchText: String?, newSearchText: String) async {
		if newSearchText.isEmpty {
			await getGames()
		} else {
			await searchGame(oldSearchText: oldSearchText, newSearchText: searchText)
		}
	}

	private func getGames() async {
		gamesTask?.cancel()

		var previousGames: [GameSearchItem] = []
		if currentPage > 1, gamesState == .success {
			previousGames = games
		}

		gamesState = .loading

		gamesTask = Task {
			do {
				let newGames = try await self.getListOfGames(page: currentPage)
				if gamesTask?.isCancelled == true {
					logger.debug("Get games cancelled")
					return
				}
				gamesState = .success
				games = previousGames + newGames
			} catch {
				logger.error("Get list of games failed", context: ["error": error])
				if gamesTask?.isCancelled == true {
					logger.debug("Get games cancelled")
					return
				}
				gamesState = .error
			}
		}

		await gamesTask?.value
	}

	private func searchGame(oldSearchText: String?, newSearchText: String) async {
		let cleanSearchText = newSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
		if cleanSearchText.isEmpty {
			currentPage = 1
			Task { await getGames() }
			logger.debug("Search text is empty, not performing a new search, reverting to the list")
			return
		}

		var previousGames: [GameSearchItem] = []
		if currentPage > 1, gamesState == .success {
			previousGames = games
		}

		gamesTask?.cancel()
		gamesState = .loading

		gamesTask = Task {
			do {
				try await Task.sleep(for: .milliseconds(150))
				await _searchGame(newSearchText, previousGames: previousGames)
			} catch {
				logger.debug("Search cancelled due to throttling")
			}
		}

		await gamesTask?.value
	}

	private func _searchGame(_ searchText: String, previousGames: [GameSearchItem]) async {
		gamesState = .loading
		do {
			let newGames = try await self.searchGame(page: currentPage, searchText: searchText)
			if gamesTask?.isCancelled == true {
				logger.debug("Search cancelled due to newer search")
				return
			}
			gamesState = .success
			games = previousGames + newGames
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
			gamesState = .error
		}
	}
}
