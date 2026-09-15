import Testing
import Foundation
import GamesLibraryCore
@testable import GamesLibrary
import BetterLogger

@Suite
@MainActor
struct GameDetailsViewModelTests {

    @Test
    func givenViewModelWhenInitializedThenStateIsLoading() {
        let mockGetGameDetails = MockGetGameDetailsUseCase()
        let viewModel = GameDetailsViewModel(
            getGameDetails: mockGetGameDetails,
            logger: BetterLogger(name: "Test")
        )
        if case .loading = viewModel.gamesState {
            #expect(Bool(true))
        } else {
            Issue.record("Expected loading state")
        }
    }

    @Test
    func givenViewModelWhenGetGameDetailsSucceedsThenStateIsSuccess() async {
        let mockGetGameDetails = MockGetGameDetailsUseCase()
        let viewModel = GameDetailsViewModel(
            getGameDetails: mockGetGameDetails,
            logger: BetterLogger(name: "Test")
        )
        mockGetGameDetails.result = .success(GameDetails.dummy(id: 42))

        await viewModel.getGameDetails(id: GameID(42))

        if case .success(let game) = viewModel.gamesState {
            #expect(game.id == GameID(42))
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test
    func givenViewModelWhenGetGameDetailsFailsThenStateIsError() async {
        let mockGetGameDetails = MockGetGameDetailsUseCase()
        let viewModel = GameDetailsViewModel(
            getGameDetails: mockGetGameDetails,
            logger: BetterLogger(name: "Test")
        )
        mockGetGameDetails.result = .failure(MockError.anyError)

        await viewModel.getGameDetails(id: GameID(1))

        if case .error = viewModel.gamesState {
            #expect(Bool(true))
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test
    func givenViewModelWhenRetryAfterFailureThenUseCaseCalledAgain() async {
        let mockGetGameDetails = MockGetGameDetailsUseCase()
        let viewModel = GameDetailsViewModel(
            getGameDetails: mockGetGameDetails,
            logger: BetterLogger(name: "Test")
        )
        mockGetGameDetails.result = .failure(MockError.anyError)
        await viewModel.getGameDetails(id: GameID(1))

        mockGetGameDetails.result = .success(GameDetails.dummy(id: 1))
        await viewModel.getGameDetails(id: GameID(1))

        #expect(mockGetGameDetails.callCount == 2)
        if case .success(let game) = viewModel.gamesState {
            #expect(game.id == GameID(1))
        } else {
            Issue.record("Expected success state after retry")
        }
    }
}
