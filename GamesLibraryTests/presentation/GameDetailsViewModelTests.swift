import Testing
import Foundation
@testable import GamesLibrary
import BetterLogger

@Suite
@MainActor
struct GameDetailsViewModelTests {

	@Test
	func givenViewModelWhenInitializedThenStateIsLoading() {
		// given
		let mockGetGameDetails = MockGetGameDetails()

		// when
		let viewModel = GameDetailsViewModel(
			getGameDetails: mockGetGameDetails,
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
	func givenViewModelWhenGetGameDetailsSucceedsThenStateIsSuccess() async {
		// given
		let mockGetGameDetails = MockGetGameDetails()
		let viewModel = GameDetailsViewModel(
			getGameDetails: mockGetGameDetails,
			logger: BetterLogger(name: "Test")
		)

		let expectedGame = Game.dummy(id: 123)
		mockGetGameDetails.result = .success(expectedGame)

		// when
		await viewModel.getGameDetails(id: 123)

		// then
		if case .success(let game) = viewModel.gamesState {
			#expect(game.id == 123)
		} else {
			Issue.record("State should be success")
		}
	}

	@Test
	func givenViewModelWhenGetGameDetailsFailsThenStateIsError() async {
		// given
		let mockGetGameDetails = MockGetGameDetails()
		let viewModel = GameDetailsViewModel(
			getGameDetails: mockGetGameDetails,
			logger: BetterLogger(name: "Test")
		)

		let expectedError = NSError(domain: "test", code: 404, userInfo: nil)
		mockGetGameDetails.result = .failure(expectedError)

		// when
		await viewModel.getGameDetails(id: 123)

		// then
		if case .error(let error) = viewModel.gamesState {
			#expect((error as NSError).code == 404)
		} else {
			Issue.record("State should be error")
		}
	}
}
