import Testing
import Foundation
import GamesLibraryCore
@testable import GamesLibrary
import BetterLogger

@Suite
@MainActor
struct GameDetailsViewModelTests {

	@Test
	func `Given View Model When Initialized Then State Is Loading`() {
		let mockGetGameDetails = MockGetGameDetailsUseCase()
		let viewModel = GameDetailsViewModel(
			getGameDetailsUseCase: mockGetGameDetails,
			logger: BetterLogger(name: "Test")
		)
		if case .loading = viewModel.gamesState {
			#expect(Bool(true))
		} else {
			Issue.record("Expected loading state")
		}
	}

	@Test
	func `Given View Model When Get Game Details Succeeds Then State Is Success`() async {
		let mockGetGameDetails = MockGetGameDetailsUseCase()
		let viewModel = GameDetailsViewModel(
			getGameDetailsUseCase: mockGetGameDetails,
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
	func `Given View Model When Get Game Details Fails Then State Is Error`() async {
		let mockGetGameDetails = MockGetGameDetailsUseCase()
		let viewModel = GameDetailsViewModel(
			getGameDetailsUseCase: mockGetGameDetails,
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
	func `Given View Model When Retry After Failure Then Use Case Called Again`() async {
		let mockGetGameDetails = MockGetGameDetailsUseCase()
		let viewModel = GameDetailsViewModel(
			getGameDetailsUseCase: mockGetGameDetails,
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

	@Test
	func `Given Stub Use Case When Get Game Details Then State Is Success`() async {
		let details = GameDetails.dummy(id: 7)
		let viewModel = GameDetailsViewModel(
			getGameDetailsUseCase: StubGetGameDetailsUseCase.constant(details),
			logger: BetterLogger(name: "Test")
		)

		await viewModel.getGameDetails(id: GameID(7))

		if case .success(let game) = viewModel.gamesState {
			#expect(game.id == GameID(7))
		} else {
			Issue.record("Expected success from StubGetGameDetailsUseCase")
		}
	}
}
