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

	func searchGame(loadNextPage: Bool = false) async {

		let searchText = self.searchText.trimmingCharacters(in: .whitespacesAndNewlines)

		gamesTask?.cancel()
		gamesState = .loading

		if loadNextPage {
			currentPage += 1
		} else {
			currentPage = 1
		}

		gamesTask = Task {
			do {
				if !searchText.isEmpty {
					try await Task.sleep(for: .milliseconds(150))
				}
				await _searchGame(searchText, previousGames: loadNextPage ? games : [])
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
