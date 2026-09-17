import Foundation
import GamesLibraryCore
import HTTIES
import BetterLogger

final class AppContainer {
	#if DEBUG
	struct Overrides {
		var gamesRepository: (any GamesRepositoryPort)?
		var urlCache: URLCache?
		var logger: BetterLogger?
		var responseInterceptors: [any HTTPResponseInterceptor]?

		static let none = Overrides()
	}

	private let overrides: Overrides
	#endif

	private let environment: AppEnvironment
	private let logger: BetterLogger
	private let jsonDecoder: JSONDecoder

	private lazy var productionURLCache: URLCache = {
		let memoryCapacity = 50 * 1024 * 1024
		let diskCapacity = 200 * 1024 * 1024
		return URLCache(
			memoryCapacity: memoryCapacity,
			diskCapacity: diskCapacity,
			diskPath: "myImageCache"
		)
	}()

	private lazy var requestInterceptors: [any HTTPRequestInterceptor] = [
		APIKeyRequestInterceptor(apiKey: environment.apiKey, logger: logger),
	]

	private lazy var responseInterceptors: [any HTTPResponseInterceptor] = {
		#if DEBUG
		if let overridden = overrides.responseInterceptors {
			return overridden
		}
		return [HTTPResponseLoggerInterceptor(logger: logger)]
		#else
		[]
		#endif
	}()

	private lazy var httpClient: any HTTPClient = HTTPClientImpl(
		httpDataRequestHandler: URLSession.shared,
		requestInterceptors: requestInterceptors,
		responseInterceptors: responseInterceptors
	)

	private lazy var productionGamesRepository: any GamesRepositoryPort = {
		GamesRepository(
			cacheDataSource: GamesCacheDataSourceImpl(timeToLive: .seconds(60 * 5)),
			networkDataSource: GamesNetworkDataSourceImpl(
				httpClient: httpClient,
				environment: environment,
				jsonDecoder: jsonDecoder
			),
			logger: logger
		)
	}()

	private var urlCache: URLCache {
		#if DEBUG
		overrides.urlCache ?? productionURLCache
		#else
		productionURLCache
		#endif
	}

	private var gamesRepository: any GamesRepositoryPort {
		#if DEBUG
		overrides.gamesRepository ?? productionGamesRepository
		#else
		productionGamesRepository
		#endif
	}

	#if DEBUG
	init(
		environment: AppEnvironment = .production,
		overrides: Overrides = .none
	) {
		self.environment = environment
		self.logger = overrides.logger ?? BetterLogger(name: "App")
		self.jsonDecoder = JSONDecoder()
		self.overrides = overrides
	}
	#else
	init(environment: AppEnvironment = .production) {
		self.environment = environment
		self.logger = BetterLogger(name: "App")
		self.jsonDecoder = JSONDecoder()
	}
	#endif

	func configureSharedURLCache() {
		URLCache.shared = urlCache
	}

	func makeSearchGamesUseCase() -> any SearchGamesUseCasePort {
		SearchGamesUseCase(repository: gamesRepository)
	}

	func makeGetGameDetailsUseCase() -> any GetGameDetailsUseCasePort {
		GetGameDetailsUseCase(repository: gamesRepository)
	}

	func makeGamesListViewModel() -> GamesListViewModel {
		GamesListViewModel(searchGames: makeSearchGamesUseCase(), logger: logger)
	}

	func makeGameDetailsViewModel() -> GameDetailsViewModel {
		GameDetailsViewModel(getGameDetails: makeGetGameDetailsUseCase(), logger: logger)
	}
}
