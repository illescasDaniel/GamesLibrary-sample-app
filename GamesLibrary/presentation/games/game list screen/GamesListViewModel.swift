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

	private let searchGame: any SearchGame
	private let logger: BetterLogger

	init(searchGame: any SearchGame, logger: BetterLogger) {
		self.searchGame = searchGame
		self.logger = logger
	}

	func getGames(oldSearchText: String?, newSearchText: String) async {
		if (oldSearchText ?? "").isEmpty {
			games = []
			currentPage = 1
		}
		await searchGame(newSearchText: newSearchText.trimmingCharacters(in: .whitespacesAndNewlines))
	}

	private func searchGame(newSearchText: String) async {
		var previousGames: [GameSearchItem] = []
		if currentPage > 1, case .success = gamesState {
			previousGames = games
		}

		gamesTask?.cancel()
		gamesState = .loading

		gamesTask = Task {
			do {
				if !newSearchText.isEmpty {
					try await Task.sleep(for: .milliseconds(150))
				}
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
