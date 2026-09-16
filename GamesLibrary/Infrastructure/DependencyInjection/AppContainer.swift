import Foundation
import GamesLibraryCore
import HTTIES
import BetterLogger

final class AppContainer {
	private let logger: BetterLogger
	private let gamesRepository: any GamesRepositoryPort
	private let urlCache: URLCache
	private let jsonDecoder: JSONDecoder

	init(environment: AppEnvironment = .production) {
		let logger = BetterLogger(name: "App")
		let jsonDecoder = JSONDecoder()
		self.logger = logger
		self.jsonDecoder = jsonDecoder

		let memoryCapacity = 50 * 1024 * 1024
		let diskCapacity = 200 * 1024 * 1024
		self.urlCache = URLCache(
			memoryCapacity: memoryCapacity,
			diskCapacity: diskCapacity,
			diskPath: "myImageCache"
		)

		#if DEBUG
		let responseInterceptors: [any HTTPResponseInterceptor] = [
			HTTPResponseLoggerInterceptor(logger: logger),
		]
		#else
		let responseInterceptors: [any HTTPResponseInterceptor] = []
		#endif

		let httpClient = HTTPClientImpl(
			httpDataRequestHandler: URLSession.shared,
			requestInterceptors: [
				APIKeyRequestInterceptor(apiKey: environment.apiKey, logger: logger),
			],
			responseInterceptors: responseInterceptors
		)

		self.gamesRepository = GamesRepository(
			cacheDataSource: GamesCacheDataSourceImpl(timeToLive: .seconds(60 * 5)),
			networkDataSource: GamesNetworkDataSourceImpl(
				httpClient: httpClient,
				environment: environment,
				jsonDecoder: jsonDecoder
			),
			logger: logger
		)
	}

	/// Preview and test seam: inject ports directly without network.
	init(
		gamesRepository: any GamesRepositoryPort,
		logger: BetterLogger = BetterLogger(name: "Preview"),
		urlCache: URLCache = URLCache(memoryCapacity: 0, diskCapacity: 0)
	) {
		self.logger = logger
		self.gamesRepository = gamesRepository
		self.urlCache = urlCache
		self.jsonDecoder = JSONDecoder()
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
