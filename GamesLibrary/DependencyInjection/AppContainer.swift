import Foundation
import GamesLibraryCore
import HTTIES
import BetterLogger

final class AppContainer: AppContaining {
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

	private lazy var httpClient: any HTTPClient = HTTPClientImpl(
		httpDataRequestHandler: URLSession.shared,
		requestInterceptors: requestInterceptors,
		responseInterceptors: []
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

	init(environment: AppEnvironment = .production) {
		self.environment = environment
		self.logger = BetterLogger(name: "App")
		self.jsonDecoder = JSONDecoder()
	}

	func configureSharedURLCache() {
		URLCache.shared = productionURLCache
	}

	func makeGamesListViewModel() -> GamesListViewModel {
		GamesListViewModel(searchGames: makeSearchGamesUseCase(), logger: logger)
	}

	func makeGameDetailsViewModel() -> GameDetailsViewModel {
		GameDetailsViewModel(getGameDetails: makeGetGameDetailsUseCase(), logger: logger)
	}

	/// Internal seam for `DebugAppContainer` forwarding — not part of `AppContaining`.
	func makeSearchGamesUseCase() -> any SearchGamesUseCasePort {
		SearchGamesUseCase(repository: productionGamesRepository)
	}

	/// Internal seam for `DebugAppContainer` forwarding — not part of `AppContaining`.
	func makeGetGameDetailsUseCase() -> any GetGameDetailsUseCasePort {
		GetGameDetailsUseCase(repository: productionGamesRepository)
	}
}
