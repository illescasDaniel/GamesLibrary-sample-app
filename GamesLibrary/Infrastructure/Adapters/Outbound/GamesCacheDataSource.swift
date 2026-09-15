import Foundation
import TTLCache

protocol GamesCacheDataSource: Sendable {
	func saveGamesCache(input: GamesInputDTO, output: GamesOutputDTO) async
	func loadGamesCache(input: GamesInputDTO) async -> GamesOutputDTO?
	func saveGameCache(id: Int, output: GameDTO) async
	func loadGameCache(id: Int) async -> GameDTO?
}

struct GamesCacheDataSourceImpl: GamesCacheDataSource {
	private let gamesCache: TTLCache<GamesInputDTO, GamesOutputDTO>
	private let gameCache: TTLCache<Int, GameDTO>

	init(timeToLive: Duration) {
		self.gamesCache = .init(timeToLive: timeToLive)
		self.gameCache = .init(timeToLive: timeToLive)
	}

	func saveGamesCache(input: GamesInputDTO, output: GamesOutputDTO) async {
		await gamesCache.store(output, forKey: input)
	}

	func loadGamesCache(input: GamesInputDTO) async -> GamesOutputDTO? {
		await gamesCache.value(forKey: input)
	}

	func saveGameCache(id: Int, output: GameDTO) async {
		await gameCache.store(output, forKey: id)
	}

	func loadGameCache(id: Int) async -> GameDTO? {
		await gameCache.value(forKey: id)
	}
}
