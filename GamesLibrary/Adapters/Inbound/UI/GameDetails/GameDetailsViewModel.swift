import Observation
import Foundation
import BetterLogger
import GamesLibraryCore

@Observable
final class GameDetailsViewModel {
	var gamesState: ViewState<GameDetails, any Error> = .loading

	private let getGameDetailsUseCase: any GetGameDetailsUseCasePort
	private let logger: BetterLogger

	init(
		getGameDetailsUseCase: any GetGameDetailsUseCasePort,
		logger: BetterLogger
	) {
		self.getGameDetailsUseCase = getGameDetailsUseCase
		self.logger = logger
	}

	func getGameDetails(id: GameID) async {
		gamesState = .loading
		do {
			let game = try await getGameDetailsUseCase(id: id)
			gamesState = .success(game)
		} catch is CancellationError {
			return
		} catch {
			logger.error("Get game details failed", context: ["error": error])
			gamesState = .error(error)
		}
	}
}
