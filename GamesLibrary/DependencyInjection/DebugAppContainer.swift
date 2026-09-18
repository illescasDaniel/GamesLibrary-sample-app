#if DEBUG
import Foundation
import GamesLibraryCore
import BetterLogger
import HTTPConveniences

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
	private let resolvedLogger: BetterLogger

	init(
		environment: AppEnvironment = .production,
		overrides: Overrides = .none
	) {
		let logger = overrides.logger ?? BetterLogger(name: "App")
		self.resolvedLogger = logger
		self.production = AppContainer(
			environment: environment,
			logger: logger,
			urlCache: overrides.urlCache,
			responseInterceptors: [HTTPResponseLoggerInterceptor { logger.info($0) }]
		)
		self.overrides = overrides
	}

	func configureSharedURLCache() {
		production.configureSharedURLCache()
	}

	func makeGamesListViewModel() -> GamesListViewModel {
		GamesListViewModel(
			searchGames: overrides.searchGamesUseCase ?? production.makeSearchGamesUseCase(),
			logger: resolvedLogger
		)
	}

	func makeGameDetailsViewModel() -> GameDetailsViewModel {
		GameDetailsViewModel(
			getGameDetailsUseCase: overrides.getGameDetailsUseCase ?? production.makeGetGameDetailsUseCase(),
			logger: resolvedLogger
		)
	}
}
#endif
