#if DEBUG
import Foundation
import GamesLibraryCore
import HTTIES
import BetterLogger

/// DEBUG composition root: wraps production `AppContainer` and applies `Overrides` when set.
final class DebugAppContainer: AppContaining {
	struct Overrides {
		var searchGamesUseCase: (any SearchGamesUseCasePort)?
		var getGameDetailsUseCase: (any GetGameDetailsUseCasePort)?
		var gamesRepository: (any GamesRepositoryPort)?
		var urlCache: URLCache?
		var logger: BetterLogger?
		var responseInterceptors: [any HTTPResponseInterceptor]?

		static let none = Overrides()

		/// Live DEBUG runs: response logging without replacing repository/use cases.
		static func debugDefaults(logger: BetterLogger = BetterLogger(name: "App")) -> Overrides {
			Overrides(
				logger: logger,
				responseInterceptors: [HTTPResponseLoggerInterceptor(logger: logger)]
			)
		}
	}

	private let production: AppContainer
	private let overrides: Overrides
	private let environment: AppEnvironment
	private let jsonDecoder = JSONDecoder()

	private var resolvedLogger: BetterLogger {
		overrides.logger ?? BetterLogger(name: "App")
	}

	private var ownsCustomNetworking: Bool {
		overrides.responseInterceptors != nil
	}

	private var needsCustomViewModels: Bool {
		overrides.searchGamesUseCase != nil
			|| overrides.getGameDetailsUseCase != nil
			|| overrides.gamesRepository != nil
			|| overrides.logger != nil
			|| ownsCustomNetworking
	}

	private lazy var debugURLCache: URLCache = {
		let memoryCapacity = 50 * 1024 * 1024
		let diskCapacity = 200 * 1024 * 1024
		return URLCache(
			memoryCapacity: memoryCapacity,
			diskCapacity: diskCapacity,
			diskPath: "myImageCache"
		)
	}()

	private lazy var debugHTTPClient: any HTTPClient = HTTPClientImpl(
		httpDataRequestHandler: URLSession.shared,
		requestInterceptors: [
			APIKeyRequestInterceptor(apiKey: environment.apiKey, logger: resolvedLogger),
		],
		responseInterceptors: overrides.responseInterceptors ?? []
	)

	private lazy var debugGamesRepository: any GamesRepositoryPort = {
		GamesRepository(
			cacheDataSource: GamesCacheDataSourceImpl(timeToLive: .seconds(60 * 5)),
			networkDataSource: GamesNetworkDataSourceImpl(
				httpClient: debugHTTPClient,
				environment: environment,
				jsonDecoder: jsonDecoder
			),
			logger: resolvedLogger
		)
	}()

	init(
		environment: AppEnvironment = .production,
		overrides: Overrides = .none
	) {
		self.environment = environment
		self.production = AppContainer(environment: environment)
		self.overrides = overrides
	}

	func configureSharedURLCache() {
		if let urlCache = overrides.urlCache {
			URLCache.shared = urlCache
		} else if ownsCustomNetworking {
			URLCache.shared = debugURLCache
		} else {
			production.configureSharedURLCache()
		}
	}

	func makeGamesListViewModel() -> GamesListViewModel {
		if needsCustomViewModels {
			return GamesListViewModel(
				searchGames: makeSearchGamesUseCase(),
				logger: resolvedLogger
			)
		}
		return production.makeGamesListViewModel()
	}

	func makeGameDetailsViewModel() -> GameDetailsViewModel {
		if needsCustomViewModels {
			return GameDetailsViewModel(
				getGameDetails: makeGetGameDetailsUseCase(),
				logger: resolvedLogger
			)
		}
		return production.makeGameDetailsViewModel()
	}

	private func makeSearchGamesUseCase() -> any SearchGamesUseCasePort {
		if let override = overrides.searchGamesUseCase {
			return override
		}
		if let repository = overrides.gamesRepository {
			return SearchGamesUseCase(repository: repository)
		}
		if ownsCustomNetworking {
			return SearchGamesUseCase(repository: debugGamesRepository)
		}
		return production.makeSearchGamesUseCase()
	}

	private func makeGetGameDetailsUseCase() -> any GetGameDetailsUseCasePort {
		if let override = overrides.getGameDetailsUseCase {
			return override
		}
		if let repository = overrides.gamesRepository {
			return GetGameDetailsUseCase(repository: repository)
		}
		if ownsCustomNetworking {
			return GetGameDetailsUseCase(repository: debugGamesRepository)
		}
		return production.makeGetGameDetailsUseCase()
	}
}
#endif
