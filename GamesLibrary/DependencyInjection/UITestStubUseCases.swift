#if DEBUG
import Foundation
import GamesLibraryCore

/// Deterministic inbound stubs for UI tests. Wired via `UITestSupport.makeOverrides()`.
/// `nonisolated` so values can seed default parameters on Sendable stub inits
/// (module uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`).
enum UITestFixtures {
	nonisolated static let defaultGames: [GameSummary] = [
		GameSummary(
			id: GameID(1),
			name: "Stub Game One",
			rating: 4.5,
			released: "2024-01-01",
			esrbRating: ESRBRating(id: 1, slug: "teen", name: "Teen"),
			platforms: [
				PlatformInfo(id: 1, name: "PC"),
				PlatformInfo(id: 2, name: "macOS"),
			]
		),
		GameSummary(
			id: GameID(2),
			name: "Stub Game Two",
			rating: 4.0,
			released: "2023-06-15",
			esrbRating: ESRBRating(id: 2, slug: "mature", name: "Mature"),
			platforms: [
				PlatformInfo(id: 3, name: "PlayStation 5"),
			]
		),
	]

	nonisolated static let defaultDetailsDescription = "Stub description for UI testing."
	nonisolated static let defaultDetailsWebsite: String? = "https://example.com/stub-game"
	nonisolated static let defaultDetailsPlaytime: Int? = 12
}

final class StubSearchGamesUseCase: SearchGamesUseCasePort, @unchecked Sendable {
	private let games: [GameSummary]

	init(games: [GameSummary]) {
		self.games = games
	}

	func callAsFunction(page: Int, searchText: String) async throws -> [GameSummary] {
		if page > 1 {
			return []
		}
		let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else {
			return games
		}
		return games.filter { ($0.name ?? "").localizedCaseInsensitiveContains(trimmed) }
	}
}

final class StubGetGameDetailsUseCase: GetGameDetailsUseCasePort, @unchecked Sendable {
	private let games: [GameSummary]
	private let descriptionRaw: String
	private let website: String?
	private let playtime: Int?
	/// How many upcoming calls should throw before succeeding.
	private var failuresRemaining: Int

	init(
		games: [GameSummary],
		failuresRemaining: Int = 0,
		descriptionRaw: String = UITestFixtures.defaultDetailsDescription,
		website: String? = UITestFixtures.defaultDetailsWebsite,
		playtime: Int? = UITestFixtures.defaultDetailsPlaytime
	) {
		self.games = games
		self.failuresRemaining = failuresRemaining
		self.descriptionRaw = descriptionRaw
		self.website = website
		self.playtime = playtime
	}

	func callAsFunction(id: GameID) async throws -> GameDetails {
		if failuresRemaining > 0 {
			failuresRemaining -= 1
			throw StubGetGameDetailsUseCaseError.forcedFailure
		}
		let summary = games.first { $0.id == id }
			?? GameSummary(
				id: id,
				name: "Stub Game \(id.rawValue)",
				rating: 4.5,
				released: "2024-01-01"
			)
		return GameDetails(
			summary: summary,
			descriptionRaw: descriptionRaw,
			website: website,
			playtime: playtime
		)
	}
}

enum StubGetGameDetailsUseCaseError: Error {
	case forcedFailure
}
#endif
