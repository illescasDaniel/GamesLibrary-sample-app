#if DEBUG
import Foundation
import GamesLibraryCore
import BetterLogger

/// DEBUG composition root: wraps production `AppContainer` and applies use-case / infra overrides.
final class DebugAppContainer: AppContaining {
	struct Overrides {
		var searchGamesUseCase: (any SearchGamesUseCasePort)?
		var getGameDetailsUseCase: (any GetGameDetailsUseCasePort)?
		var urlCache: URLCache?
		var logger: BetterLogger?

		static let none = Overrides()
	}

	private let production: AppContainer
	private let overrides: Overrides

	private var resolvedLogger: BetterLogger {
		overrides.logger ?? BetterLogger(name: "App")
	}

	init(
		environment: AppEnvironment = .production,
		overrides: Overrides = .none
	) {
		self.production = AppContainer(environment: environment)
		self.overrides = overrides
	}

	func configureSharedURLCache() {
		if let urlCache = overrides.urlCache {
			URLCache.shared = urlCache
		} else {
			production.configureSharedURLCache()
		}
	}

	func makeGamesListViewModel() -> GamesListViewModel {
		GamesListViewModel(
			searchGames: overrides.searchGamesUseCase ?? production.makeSearchGamesUseCase(),
			logger: resolvedLogger
		)
	}

	func makeGameDetailsViewModel() -> GameDetailsViewModel {
		GameDetailsViewModel(
			getGameDetails: overrides.getGameDetailsUseCase ?? production.makeGetGameDetailsUseCase(),
			logger: resolvedLogger
		)
	}
}
#endif
