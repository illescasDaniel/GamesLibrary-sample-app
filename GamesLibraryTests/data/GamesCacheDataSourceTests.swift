import Testing
import Foundation
@testable import GamesLibrary

@Suite
@MainActor
struct GamesCacheDataSourceTests {

	@Test
	func `Given Data Source When Saving And Loading Games Then Result Is Correct`() async {
		let dataSource = GamesCacheDataSourceImpl(timeToLive: .seconds(60))
		let input = GamesInputDTO.dummy(page: 1, pageSize: 20)
		let output = GamesOutputDTO.dummy(results: [GameSearchItemDTO.dummy(id: 1)])

		await dataSource.saveGamesCache(input: input, output: output)
		let cached = await dataSource.loadGamesCache(input: input)

		#expect(cached?.results.first?.id == 1)
	}

	@Test
	func `Given Data Source When Saving And Loading Game Details Then Result Is Correct`() async {
		let dataSource = GamesCacheDataSourceImpl(timeToLive: .seconds(60))
		let game = GameDTO.dummy(id: 123)

		await dataSource.saveGameCache(id: 123, output: game)
		let cached = await dataSource.loadGameCache(id: 123)

		#expect(cached?.id == 123)
	}

	@Test
	func `Given Data Source With Expired TTL When Loading Then Returns Nil`() async throws {
		let dataSource = GamesCacheDataSourceImpl(timeToLive: .milliseconds(1))
		let game = GameDTO.dummy(id: 123)

		await dataSource.saveGameCache(id: 123, output: game)
		try await Task.sleep(for: .milliseconds(2))
		let cached = await dataSource.loadGameCache(id: 123)

		#expect(cached == nil)
	}
}
