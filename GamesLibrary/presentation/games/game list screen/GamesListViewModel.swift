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
	var searchGameTask: Task<Void, Never>?

	private let getListOfGames: any GetListOfGames
	private let searchGame: any SearchGame
	private let logger: BetterLogger

	init(getListOfGames: any GetListOfGames, searchGame: any SearchGame, logger: BetterLogger) {
		self.getListOfGames = getListOfGames
		self.searchGame = searchGame
		self.logger = logger
	}

	func getListOfGames() async {
		gamesState = .loading
		do {
			let games = try await self.getListOfGames(page: currentPage)
			gamesState = .success(games)
		} catch {
			logger.error("Get list of games failed", context: ["error": error])
			gamesState = .error(error)
		}
	}

	func searchGame(oldSearchText: String?, newSearchText: String) {
		let cleanSearchText = newSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
		if oldSearchText == cleanSearchText {
			logger.debug("Old search text is equivalent to the new one, not performing a new search")
			return
		}
		if cleanSearchText.isEmpty {
			Task { await getListOfGames() }
			logger.debug("Search text is empty, not performing a new search, reverting to the list")
			return
		}

		searchGameTask?.cancel()
		gamesState = .loading

		searchGameTask = Task {
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
			if searchGameTask?.isCancelled == true {
				logger.debug("Search cancelled due to newer search")
				return
			}
			gamesState = .success(games)
		} catch {
			if searchGameTask?.isCancelled == true {
				logger.debug("Search cancelled due to newer search")
				return
			}
			logger.error("Search failed", context: ["error": error])
			gamesState = .error(error)
			// TODO: some times we might get a cancellation error from urlsession
		}
	}
}
