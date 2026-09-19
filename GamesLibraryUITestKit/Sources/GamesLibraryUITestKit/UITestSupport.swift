import Foundation
import AccessibilityIdentifiers
import GamesLibraryCore

public enum UITestSupport {
	public struct StubTables {
		public var searchResponses: [SearchStubKey: [GameSummary]]
		public var gamesForDetails: [GameSummary]
		public var detailsResponses: [GameID: [DetailsStubOutcome]]
	}

	private static var configurationJSON: String? {
		ProcessInfo.processInfo.environment[UITestEnvironment.configKey]
	}

	public static var isSharedProcessUITesting: Bool {
		ProcessInfo.processInfo.environment[UITestEnvironment.testingKey] == "1"
	}

	public static var isRunningUITests: Bool {
		isSharedProcessUITesting || configurationJSON != nil
	}

	public static func initialConfiguration() -> UITestConfiguration? {
		guard let raw = configurationJSON else { return nil }
		return UITestConfiguration.decodeIfPresent(fromLaunchEnvironmentValue: raw)
	}

	public static func makeStubTables(from configuration: UITestConfiguration) -> StubTables {
		let searchStub = makeSearchStub(from: configuration.gamesList)
		let detailsResponses = makeDetailsStub(
			from: configuration.gameDetails,
			fallbackGames: searchStub.gamesForDetails
		)
		return StubTables(
			searchResponses: searchStub.responses,
			gamesForDetails: searchStub.gamesForDetails,
			detailsResponses: detailsResponses
		)
	}

	private static func makeSearchStub(
		from gamesList: UITestConfiguration.GamesList
	) -> (responses: [SearchStubKey: [GameSummary]], gamesForDetails: [GameSummary]) {
		guard let configured = gamesList.responses else {
			return (
				[SearchStubKey(page: 1, searchText: ""): UITestFixtures.defaultGames],
				UITestFixtures.defaultGames
			)
		}

		var responses: [SearchStubKey: [GameSummary]] = [:]
		var gamesForDetails: [GameSummary] = []
		var seenIDs = Set<GameID>()

		for (rawKey, fixtures) in configured {
			guard let key = SearchStubKey(encoded: rawKey) else {
				preconditionFailure("Invalid search stub key: \(rawKey)")
			}
			let games = fixtures.map { $0.toDomain() }
			responses[key] = games
			for game in games where seenIDs.insert(game.id).inserted {
				gamesForDetails.append(game)
			}
		}

		return (responses, gamesForDetails)
	}

	private static func makeDetailsStub(
		from gameDetails: UITestConfiguration.GameDetails,
		fallbackGames: [GameSummary]
	) -> [GameID: [DetailsStubOutcome]] {
		if let configured = gameDetails.responses {
			return Dictionary(uniqueKeysWithValues: configured.map { id, outcomes in
				(GameID(id), outcomes.map { $0.toDomain() })
			})
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
		return responses
	}
}
