#if DEBUG
import Foundation
import GamesLibraryCore
import GamesLibraryUITestKit
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
	private let scenarioHost: UITestScenarioHost?
	private let resolvedLogger: BetterLogger

	init(
		environment: AppEnvironment = .production,
		overrides: Overrides = .none,
		scenarioHost: UITestScenarioHost? = nil
	) {
		let logger = overrides.logger ?? BetterLogger(name: "App")
		self.resolvedLogger = logger
		let urlCache = overrides.urlCache ?? (scenarioHost != nil
			? URLCache(memoryCapacity: 0, diskCapacity: 0)
			: nil)
		self.production = AppContainer(
			environment: environment,
			logger: logger,
			urlCache: urlCache,
			responseInterceptors: [HTTPResponseLoggerInterceptor { logger.info($0) }]
		)
		self.overrides = overrides
		self.scenarioHost = scenarioHost
	}

	func configureSharedURLCache() {
		production.configureSharedURLCache()
	}

	func makeGamesListViewModel() -> GamesListViewModel {
		GamesListViewModel(
			searchGames: scenarioHost?.searchGamesUseCase
				?? overrides.searchGamesUseCase
				?? production.makeSearchGamesUseCase(),
			logger: resolvedLogger
		)
	}

	func makeGameDetailsViewModel() -> GameDetailsViewModel {
		GameDetailsViewModel(
			getGameDetailsUseCase: scenarioHost?.getGameDetailsUseCase
				?? overrides.getGameDetailsUseCase
				?? production.makeGetGameDetailsUseCase(),
			logger: resolvedLogger
		)
	}
}
#endif
