import Testing
import Foundation
import GamesLibraryCore
@testable import GamesLibrary
import BetterLogger

@Suite
@MainActor
struct GamesListViewModelTests {

    @Test
    func givenViewModelWhenInitializedThenStateIsLoading() {
        let mockSearchGames = MockSearchGamesUseCase()
        let viewModel = GamesListViewModel(
            searchGames: mockSearchGames,
            logger: BetterLogger(name: "Test")
        )
        #expect(viewModel.gamesState == .loading)
    }

    @Test
    func givenViewModelWhenSearchSucceedsThenStateIsSuccess() async {
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
    func givenViewModelWhenSearchFailsThenStateIsError() async {
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
    func givenViewModelWhenSearchIsThrottledThenReturnsSuccess() async {
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
    func givenViewModelWhenLoadingNextPageThenGamesAreAppended() async {
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
    func givenViewModelWhenSearchReturnsEmptyThenStateIsSuccessEmpty() async {
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
    func givenViewModelWhenNextPageReturnsEmptyThenStateRemainsSuccess() async {
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
    func givenViewModelWhenSearchWithoutLoadNextPageThenPageIsOne() async {
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
    func givenViewModelWhenURLSessionCancelledThenStateRemainsSuccess() async {
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
