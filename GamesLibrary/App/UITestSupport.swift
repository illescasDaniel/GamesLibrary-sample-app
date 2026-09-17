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
		let searchStub = makeSearchStub(from: configuration.gamesList)
		return DebugAppContainer.Overrides(
			searchGamesUseCase: searchStub.useCase,
			getGameDetailsUseCase: makeDetailsStub(
				from: configuration.gameDetails,
				fallbackGames: searchStub.gamesForDetails
			),
			urlCache: URLCache(memoryCapacity: 0, diskCapacity: 0)
		)
	}

	private static func makeSearchStub(
		from gamesList: UITestConfiguration.GamesList
	) -> (useCase: StubSearchGamesUseCase, gamesForDetails: [GameSummary]) {
		guard let configured = gamesList.responses else {
			return (
				StubSearchGamesUseCase.constant(UITestFixtures.defaultGames),
				UITestFixtures.defaultGames
			)
		}

		var responses: [SearchStubKey: [GameSummary]] = [:]
		var gamesForDetails: [GameSummary] = []
		var seenIDs = Set<GameID>()

		for entry in configured {
			let games = entry.games.map { $0.toDomain() }
			responses[SearchStubKey(page: entry.page, searchText: entry.searchText)] = games
			for game in games where seenIDs.insert(game.id).inserted {
				gamesForDetails.append(game)
			}
		}

		return (StubSearchGamesUseCase(responses: responses), gamesForDetails)
	}

	private static func makeDetailsStub(
		from gameDetails: UITestConfiguration.GameDetails,
		fallbackGames: [GameSummary]
	) -> StubGetGameDetailsUseCase {
		if let configured = gameDetails.responses {
			var responses: [GameID: [DetailsStubOutcome]] = [:]
			for entry in configured {
				responses[GameID(entry.id)] = entry.outcomes.map { $0.toDomain() }
			}
			return StubGetGameDetailsUseCase(responses: responses)
		}

		var responses: [GameID: [DetailsStubOutcome]] = [:]
		for game in fallbackGames {
			let details = UITestFixtures.defaultDetailsByID[game.id]
				?? GameDetails(
					summary: game,
					descriptionRaw: UITestConfiguration.GameDetailsFixture.stubGameOne.descriptionRaw,
					website: UITestConfiguration.GameDetailsFixture.stubGameOne.website,
					playtime: UITestConfiguration.GameDetailsFixture.stubGameOne.playtime
				)
			responses[game.id] = [.success(details)]
		}
		return StubGetGameDetailsUseCase(responses: responses)
	}
}
#endif
