import Testing
import Foundation
@testable import GamesLibrary
import BetterLogger
import HTTIES

@Suite
@MainActor
struct GamesListViewModelTests {

	@Test
	func givenViewModelWhenInitializedThenStateIsLoading() {
		// given
		let mockSearchGame = MockSearchGame()

		// when
		let viewModel = GamesListViewModel(
			searchGame: mockSearchGame,
			logger: BetterLogger(name: "Test")
		)

		// then
		#expect(viewModel.gamesState == .loading)
	}

	@Test
	func givenViewModelWhenSearchSucceedsThenStateIsSuccess() async {
		// given
		let mockSearchGame = MockSearchGame()
		let viewModel = GamesListViewModel(
			searchGame: mockSearchGame,
			logger: BetterLogger(name: "Test")
		)

		let expectedGames = [GameSearchItem.dummy(id: 1, name: "Game 1")]
		mockSearchGame.result = .success(expectedGames)

		// when
		viewModel.searchText = "Test"
		await viewModel.searchGame()

		// then
		#expect(viewModel.gamesState == .success(isEmpty: false))
		#expect(viewModel.games.count == 1)
		#expect(viewModel.games.first?.id == 1)
	}

	@Test
	func givenViewModelWhenSearchFailsThenStateIsError() async {
		// given
		let mockSearchGame = MockSearchGame()
		let viewModel = GamesListViewModel(
			searchGame: mockSearchGame,
			logger: BetterLogger(name: "Test")
		)

		let expectedError = NSError(domain: "test", code: 1, userInfo: nil)
		mockSearchGame.result = .failure(expectedError)

		// when
		viewModel.searchText = "Test"
		await viewModel.searchGame()

		// then
		#expect(viewModel.gamesState == .error)
	}

	@Test
	func givenViewModelWhenSearchIsThrottledThenReturnsSuccess() async {
		// given
		let mockSearchGame = MockSearchGame()
		mockSearchGame.result = .success([])
		let viewModel = GamesListViewModel(
			searchGame: mockSearchGame,
			logger: BetterLogger(name: "Test")
		)

		viewModel.searchText = "Test"
		
		// when
		// We start two searches rapidly
		let task1 = Task { await viewModel.searchGame() }
		viewModel.searchText = "Test 2"
		let task2 = Task { await viewModel.searchGame() }
		
		await task1.value
		await task2.value

		// then
		// The first one should have been cancelled/throttled, and the second one should complete
		#expect(viewModel.gamesState == .success(isEmpty: true))
	}

	@Test
	func givenViewModelWhenSearchReturns404ThenStateIsSuccessEmpty() async {
		// given
		let mockSearchGame = MockSearchGame()
		let viewModel = GamesListViewModel(
			searchGame: mockSearchGame,
			logger: BetterLogger(name: "Test")
		)

		// Mock 404 error
		let error404 = AppNetworkResponseError.unexpected(statusCode: 404)
		mockSearchGame.result = .failure(error404)

		// when
		viewModel.searchText = "Test"
		await viewModel.searchGame()

		// then
		#expect(viewModel.gamesState == .success(isEmpty: true))
	}

	@Test
	func givenViewModelWhenLoadingNextPageThenGamesAreAppended() async {
		// given
		let mockSearchGame = MockSearchGame()
		let viewModel = GamesListViewModel(
			searchGame: mockSearchGame,
			logger: BetterLogger(name: "Test")
		)

		let firstPageGames = [GameSearchItem.dummy(id: 1)]
		mockSearchGame.result = .success(firstPageGames)
		await viewModel.searchGame()

		let secondPageGames = [GameSearchItem.dummy(id: 2)]
		mockSearchGame.result = .success(secondPageGames)

		// when
		await viewModel.searchGame(loadNextPage: true)

		// then
		#expect(viewModel.games.count == 2)
		#expect(viewModel.games.map(\.id) == [1, 2])
		#expect(viewModel.currentPage == 2)
	}
}
