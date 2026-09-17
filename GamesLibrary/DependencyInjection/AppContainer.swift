import Foundation
import GamesLibraryCore
import HTTIES
import BetterLogger

final class AppContainer {
	private let environment: AppEnvironment
	private let logger: BetterLogger
	private let jsonDecoder: JSONDecoder
	private let gamesRepositoryOverride: (any GamesRepositoryPort)?
	private let urlCacheOverride: URLCache?

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
		[HTTPResponseLoggerInterceptor(logger: logger)]
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
		urlCacheOverride ?? productionURLCache
	}

	private var gamesRepository: any GamesRepositoryPort {
		gamesRepositoryOverride ?? productionGamesRepository
	}

	init(environment: AppEnvironment = .production) {
		self.environment = environment
		self.logger = BetterLogger(name: "App")
		self.jsonDecoder = JSONDecoder()
		self.gamesRepositoryOverride = nil
		self.urlCacheOverride = nil
	}

	/// Preview and test seam: inject ports directly without network.
	init(
		gamesRepository: any GamesRepositoryPort,
		logger: BetterLogger = BetterLogger(name: "Preview"),
		urlCache: URLCache = URLCache(memoryCapacity: 0, diskCapacity: 0)
	) {
		self.environment = .production
		self.logger = logger
		self.jsonDecoder = JSONDecoder()
		self.gamesRepositoryOverride = gamesRepository
		self.urlCacheOverride = urlCache
	}

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
