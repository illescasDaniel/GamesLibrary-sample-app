//
//  GamesListViewModel.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Observation

@Observable
final class GamesListViewModel {

	var gamesState: ViewState<[Game], any Error> = .loading
	var currentPage: Int = 1

	private let getListOfGames: any GetListOfGames
	private let searchGame: any SearchGame

	init(getListOfGames: any GetListOfGames, searchGame: any SearchGame) {
		self.getListOfGames = getListOfGames
		self.searchGame = searchGame
	}

	func getListOfGames() async {
		self.gamesState = .loading
		do {
			let games = try await getListOfGames(page: currentPage)
			self.gamesState = .success(games)
		} catch {
			self.gamesState = .error(error)
		}
	}

	func searchGame(_ name: String) async {
		do {
			let games = try await searchGame(page: currentPage, searchText: name)
			self.gamesState = .success(games)
		} catch {
			self.gamesState = .error(error)
		}
	}
}
