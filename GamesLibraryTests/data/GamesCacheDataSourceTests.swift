import Testing
import Foundation
@testable import GamesLibrary

@Suite
@MainActor
struct GamesCacheDataSourceTests {

	@Test
	func givenDataSourceWhenSavingAndLoadingGamesThenResultIsCorrect() async {
		// given
		let dataSource = GamesCacheDataSourceImpl(timeToLive: .seconds(60))
		let input = GamesInput.dummy(page: 1, pageSize: 20)
		let output = GamesOutput(count: 1, next: nil, previous: nil, results: [GameSearchItem.dummy(id: 1)])

		// when
		await dataSource.saveGamesCache(input: input, output: output)
		let cached = await dataSource.loadGamesCache(input: input)

		// then
		#expect(cached?.results.first?.id == 1)
	}

	@Test
	func givenDataSourceWhenSavingAndLoadingGameDetailsThenResultIsCorrect() async {
		// given
		let dataSource = GamesCacheDataSourceImpl(timeToLive: .seconds(60))
		let game = Game.dummy(id: 123)

		// when
		await dataSource.saveGameCache(id: 123, output: game)
		let cached = await dataSource.loadGameCache(id: 123)

		// then
		#expect(cached?.id == 123)
	}

	@Test
	func givenDataSourceWithNoTTLWhenSavingAndLoadingGameDetailsThenResultIsCorrect() async throws {
		// given
		let dataSource = GamesCacheDataSourceImpl(timeToLive: .milliseconds(1))
		let game = Game.dummy(id: 123)

		// when
		await dataSource.saveGameCache(id: 123, output: game)
		try await Task.sleep(for: .milliseconds(2))
		let cached = await dataSource.loadGameCache(id: 123)

		// then
		#expect(cached == nil)
	}
}
