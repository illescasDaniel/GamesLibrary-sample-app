import Testing
import Foundation
@testable import GamesLibrary
import BetterLogger

@Suite
@MainActor
struct GamesListViewModelTests {

	@Test
	func givenViewModelWhenInitializedThenStateIsLoading() {
		// given
		let mockGetListOfGames = MockGetListOfGames()
		let mockSearchGame = MockSearchGame()

		// when
		let viewModel = GamesListViewModel(
			getListOfGames: mockGetListOfGames,
			searchGame: mockSearchGame,
			logger: BetterLogger(name: "Test")
		)

		// then
		if case .loading = viewModel.gamesState {
			// Success
		} else {
			Issue.record("Initial state should be loading")
		}
	}

	@Test
	func givenViewModelWhenGetGamesSucceedsThenStateIsSuccess() async {
		// given
		let mockGetListOfGames = MockGetListOfGames()
		let mockSearchGame = MockSearchGame()
		let viewModel = GamesListViewModel(
			getListOfGames: mockGetListOfGames,
			searchGame: mockSearchGame,
			logger: BetterLogger(name: "Test")
		)

		let expectedGames = [GameSearchItem.dummy(id: 1, name: "Game 1")]
		mockGetListOfGames.result = .success(expectedGames)

		// when
		await viewModel.getGames()

		// then
		if case .success(let games) = viewModel.gamesState {
			#expect(games.count == 1)
			#expect(games.first?.id == 1)
		} else {
			Issue.record("State should be success")
		}
	}

	@Test
	func givenViewModelWhenGetGamesFailsThenStateIsError() async {
		// given
		let mockGetListOfGames = MockGetListOfGames()
		let mockSearchGame = MockSearchGame()
		let viewModel = GamesListViewModel(
			getListOfGames: mockGetListOfGames,
			searchGame: mockSearchGame,
			logger: BetterLogger(name: "Test")
		)

		let expectedError = NSError(domain: "test", code: 1, userInfo: nil)
		mockGetListOfGames.result = .failure(expectedError)

		// when
		await viewModel.getGames()

		// then
		if case .error(let error) = viewModel.gamesState {
			#expect((error as NSError).code == 1)
		} else {
			Issue.record("State should be error")
		}
	}

	@Test
	func givenViewModelWhenSearchGameSucceedsThenStateIsSuccess() async {
		// given
		let mockGetListOfGames = MockGetListOfGames()
		let mockSearchGame = MockSearchGame()
		let viewModel = GamesListViewModel(
			getListOfGames: mockGetListOfGames,
			searchGame: mockSearchGame,
			logger: BetterLogger(name: "Test")
		)

		let expectedGames = [GameSearchItem.dummy(id: 2, name: "Searched Game")]
		mockSearchGame.result = .success(expectedGames)

		// when
		viewModel.searchGame(oldSearchText: "", newSearchText: "Test")
		
		// Wait for the task to complete
		await viewModel.gamesTask?.value

		// then
		if case .success(let games) = viewModel.gamesState {
			#expect(games.count == 1)
			#expect(games.first?.name == "Searched Game")
		} else {
			Issue.record("State should be success")
		}
	}
}
