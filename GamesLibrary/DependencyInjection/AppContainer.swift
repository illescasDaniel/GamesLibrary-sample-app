import Foundation
import GamesLibraryCore
import HTTIES
import BetterLogger
import HTTPConveniences

final class AppContainer: AppContaining {
	private let environment: AppEnvironment
	private let logger: BetterLogger
	private let jsonDecoder: JSONDecoder
	private let urlCache: URLCache
	private let httpDataRequestHandler: any HTTPDataRequestHandler
	private let requestInterceptors: [any HTTPRequestInterceptor]
	private let responseInterceptors: [any HTTPResponseInterceptor]

	private lazy var httpClient: any HTTPClient = HTTPClientImpl(
		httpDataRequestHandler: httpDataRequestHandler,
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

	/// - Parameter requestInterceptors: `nil` installs the production API-key interceptor; pass an explicit array (including `[]`) to replace it.
	/// - Parameter urlCache: `nil` installs the production image `URLCache`; pass a concrete cache to replace it.
	/// - Parameter responseInterceptors: DEBUG composition may pass logging interceptors; Release uses the default empty list.
	init(
		environment: AppEnvironment = .production,
		logger: BetterLogger = BetterLogger(name: "App"),
		urlCache: URLCache? = nil,
		httpDataRequestHandler: any HTTPDataRequestHandler = URLSession.shared,
		requestInterceptors: [any HTTPRequestInterceptor]? = nil,
		responseInterceptors: [any HTTPResponseInterceptor] = [],
		jsonDecoder: JSONDecoder = JSONDecoder()
	) {
		self.environment = environment
		self.logger = logger
		self.jsonDecoder = jsonDecoder
		self.urlCache = urlCache ?? Self.makeDefaultURLCache()
		self.httpDataRequestHandler = httpDataRequestHandler
		self.requestInterceptors = requestInterceptors ?? [
			QueryItemRequestInterceptor(name: "key", value: environment.apiKey),
		]
		self.responseInterceptors = responseInterceptors
	}

	func configureSharedURLCache() {
		URLCache.shared = urlCache
	}

	func makeGamesListViewModel() -> GamesListViewModel {
		GamesListViewModel(searchGames: makeSearchGamesUseCase(), logger: logger)
	}

	func makeGameDetailsViewModel() -> GameDetailsViewModel {
		GameDetailsViewModel(
			getGameDetailsUseCase: makeGetGameDetailsUseCase(),
			logger: logger
		)
	}

	/// Internal seam for `DebugAppContainer` forwarding — not part of `AppContaining`.
	func makeSearchGamesUseCase() -> any SearchGamesUseCasePort {
		SearchGamesUseCase(repository: productionGamesRepository)
	}

	/// Internal seam for `DebugAppContainer` forwarding — not part of `AppContaining`.
	func makeGetGameDetailsUseCase() -> any GetGameDetailsUseCasePort {
		GetGameDetailsUseCase(repository: productionGamesRepository)
	}

	private static func makeDefaultURLCache() -> URLCache {
		let memoryCapacity = 50 * 1024 * 1024
		let diskCapacity = 200 * 1024 * 1024
		return URLCache(
			memoryCapacity: memoryCapacity,
			diskCapacity: diskCapacity,
			diskPath: "myImageCache"
		)
	}
}
