import Testing
import Foundation
import GamesLibraryCore
@testable import GamesLibrary
import BetterLogger
import ViewLoadState

@Suite
@MainActor
struct GamesListViewModelTests {

	@Test
	func `Given View Model When Initialized Then State Is Loading`() {
		let mockSearchGames = MockSearchGamesUseCase()
		let viewModel = GamesListViewModel(
			searchGames: mockSearchGames,
			logger: BetterLogger(name: "Test")
		)
		#expect(viewModel.gamesState == .loading)
	}

	@Test
	func `Given View Model When Search Succeeds Then State Is Success`() async {
		let mockSearchGames = MockSearchGamesUseCase()
		let viewModel = GamesListViewModel(
			searchGames: mockSearchGames,
			logger: BetterLogger(name: "Test")
		)
		mockSearchGames.result = .success([GameSummary.dummy(id: 1, name: "Game 1")])

		viewModel.searchText = "Test"
		await viewModel.searchGame()

		#expect(viewModel.gamesState == .success(isEmpty: false))
		#expect(viewModel.games.count == 1)
		#expect(viewModel.games.first?.id == GameID(1))
	}

	@Test
	func `Given View Model When Search Fails Then State Is Error`() async {
		let mockSearchGames = MockSearchGamesUseCase()
		let viewModel = GamesListViewModel(
			searchGames: mockSearchGames,
			logger: BetterLogger(name: "Test")
		)
		mockSearchGames.result = .failure(NSError(domain: "test", code: 1))

		viewModel.searchText = "Test"
		await viewModel.searchGame()

		#expect(viewModel.gamesState == .error)
	}

	@Test
	func `Given View Model When Search Is Throttled Then Returns Success`() async {
		let mockSearchGames = MockSearchGamesUseCase()
		mockSearchGames.result = .success([])
		let viewModel = GamesListViewModel(
			searchGames: mockSearchGames,
			logger: BetterLogger(name: "Test")
		)
		viewModel.searchText = "Test"

		let task1 = Task { await viewModel.searchGame() }
		viewModel.searchText = "Test 2"
		let task2 = Task { await viewModel.searchGame() }
		await task1.value
		await task2.value

		#expect(viewModel.gamesState == .success(isEmpty: true))
	}

	@Test
	func `Given View Model When Loading Next Page Then Games Are Appended`() async {
		let mockSearchGames = MockSearchGamesUseCase()
		let viewModel = GamesListViewModel(
			searchGames: mockSearchGames,
			logger: BetterLogger(name: "Test")
		)
		mockSearchGames.result = .success([GameSummary.dummy(id: 1)])
		await viewModel.searchGame()

		mockSearchGames.result = .success([GameSummary.dummy(id: 2)])
		await viewModel.searchGame(loadNextPage: true)

		#expect(viewModel.games.count == 2)
		#expect(viewModel.games.map(\.id.rawValue) == [1, 2])
		#expect(viewModel.currentPage == 2)
	}

	@Test
	func `Given View Model When Search Returns Empty Then State Is Success Empty`() async {
		let mockSearchGames = MockSearchGamesUseCase()
		let viewModel = GamesListViewModel(
			searchGames: mockSearchGames,
			logger: BetterLogger(name: "Test")
		)
		mockSearchGames.result = .success([])
		viewModel.searchText = "NoMatchQuery"

		await viewModel.searchGame()

		#expect(viewModel.gamesState == .success(isEmpty: true))
		#expect(viewModel.games.isEmpty)
	}

	@Test
	func `Given View Model When Next Page Returns Empty Then State Remains Success`() async {
		let mockSearchGames = MockSearchGamesUseCase()
		let viewModel = GamesListViewModel(
			searchGames: mockSearchGames,
			logger: BetterLogger(name: "Test")
		)
		mockSearchGames.result = .success([GameSummary.dummy(id: 1)])
		await viewModel.searchGame()

		mockSearchGames.result = .success([])
		await viewModel.searchGame(loadNextPage: true)

		#expect(viewModel.gamesState == .success(isEmpty: false))
		#expect(viewModel.games.count == 1)
		#expect(viewModel.games.first?.id == GameID(1))
	}

	@Test
	func `Given View Model When Search Without Load Next Page Then Page Is One`() async {
		let mockSearchGames = MockSearchGamesUseCase()
		let viewModel = GamesListViewModel(
			searchGames: mockSearchGames,
			logger: BetterLogger(name: "Test")
		)
		mockSearchGames.result = .success([GameSummary.dummy(id: 1)])
		viewModel.currentPage = 5

		await viewModel.searchGame()

		#expect(viewModel.currentPage == 1)
	}

	@Test
	func `Given View Model When URL Session Cancelled Then State Remains Success`() async {
		let mockSearchGames = MockSearchGamesUseCase()
		let viewModel = GamesListViewModel(
			searchGames: mockSearchGames,
			logger: BetterLogger(name: "Test")
		)
		mockSearchGames.result = .success([GameSummary.dummy(id: 1)])
		await viewModel.searchGame()

		mockSearchGames.result = .failure(NSError(domain: NSURLErrorDomain, code: URLError.cancelled.rawValue))
		await viewModel.searchGame(loadNextPage: true)

		#expect(viewModel.gamesState == .success(isEmpty: false))
		#expect(viewModel.games.count == 1)
	}
}
