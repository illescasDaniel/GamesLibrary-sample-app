//
//  GamesListViewModel.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Observation
import Foundation
import BetterLogger
import HTTIES

@Observable
final class GamesListViewModel {

	var games: [GameSearchItem] = []
	var gamesState: ListViewState = .loading
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
		if currentPage > 1, case .success = gamesState {
			previousGames = games
		}

		gamesState = .loading

		gamesTask = Task {
			do {
				let newGames = try await self.getListOfGames(page: currentPage)
				if gamesTask?.isCancelled == true {
					logger.debug("Get games cancelled")
					setSuccessState()
					return
				}
				games = previousGames + newGames
				setSuccessState()
			} catch {
				logger.error("Get list of games failed", context: ["error": error])
				if gamesTask?.isCancelled == true {
					logger.debug("Get games cancelled")
					gamesState = .success(isEmpty: games.isEmpty)
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
		if currentPage > 1, case .success = gamesState {
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
				setSuccessState()
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
				setSuccessState()
				return
			}
			games = previousGames + newGames
			setSuccessState()
		} catch {
			logger.error("Search failed", context: ["error": error])
			if gamesTask?.isCancelled == true {
				logger.debug("Search cancelled due to newer search")
				setSuccessState()
				return
			}
			if (error as NSError).code == URLError.cancelled.rawValue {
				logger.debug("Search cancelled at URL Session level")
				setSuccessState()
				return
			}
			if case let AppNetworkResponseError.unexpected(statusCode) = error, statusCode == 404 {
				logger.debug("Search endpoint can return 404 when no further results are found")
				setSuccessState()
				return
			}
			gamesState = .error
		}
	}

	private func setSuccessState() {
		gamesState = .success(isEmpty: games.isEmpty)
	}
}
