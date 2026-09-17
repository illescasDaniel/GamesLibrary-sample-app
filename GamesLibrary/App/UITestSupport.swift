#if DEBUG
import Foundation
import AccessibilityIdentifiers
import GamesLibraryCore

enum UITestSupport {
	private static var configurationJSON: String? {
		ProcessInfo.processInfo.environment[UITestEnvironment.configKey]
	}

	static var isRunningUITests: Bool {
		configurationJSON != nil
	}

	/// Maps `UITEST_CONFIG` to composition-root use-case overrides for deterministic UI tests.
	static func makeOverrides() -> DebugAppContainer.Overrides? {
		guard let raw = configurationJSON else { return nil }
		let configuration = UITestConfiguration.decode(fromLaunchEnvironmentValue: raw)
		let games = configuration.gamesList.emptyResults ? [] : UITestFixtures.defaultGames
		return DebugAppContainer.Overrides(
			searchGamesUseCase: StubSearchGamesUseCase(games: games),
			getGameDetailsUseCase: StubGetGameDetailsUseCase(
				games: games,
				failuresRemaining: configuration.gameDetails.failuresRemaining
			),
			urlCache: URLCache(memoryCapacity: 0, diskCapacity: 0)
		)
	}
}
#endif
