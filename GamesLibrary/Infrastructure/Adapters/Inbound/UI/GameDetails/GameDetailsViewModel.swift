import Observation
import Foundation
import BetterLogger
import GamesLibraryCore

@Observable
final class GameDetailsViewModel {
	var gamesState: ViewState<GameDetails, any Error> = .loading

	private let getGameDetails: any GetGameDetailsUseCasePort
	private let logger: BetterLogger

	init(getGameDetails: any GetGameDetailsUseCasePort, logger: BetterLogger) {
		self.getGameDetails = getGameDetails
		self.logger = logger
	}

	func getGameDetails(id: GameID) async {
		gamesState = .loading
		do {
			let game = try await getGameDetails(id: id)
			gamesState = .success(game)
		} catch {
			logger.error("Get game details failed", context: ["error": error])
			gamesState = .error(error)
		}
	}
}
