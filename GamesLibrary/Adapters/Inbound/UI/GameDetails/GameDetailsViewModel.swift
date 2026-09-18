import Observation
import Foundation
import BetterLogger
import GamesLibraryCore
import ViewLoadState

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
		// Keep an existing `.success` visible while refreshing so a cancelled SwiftUI
		// `.task` (common in Previews) cannot wipe content back to a stuck loading overlay.
		if case .success = gamesState {
			// refresh without clearing
		} else {
			gamesState = .loading
		}
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

	#if DEBUG
	/// First-frame Preview content. Stub remains wired for Retry / later `.task` loads.
	@discardableResult
	func previewSucceeding(_ details: GameDetails) -> GameDetailsViewModel {
		gamesState = .success(details)
		return self
	}
	#endif
}
