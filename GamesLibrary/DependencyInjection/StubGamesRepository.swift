#if DEBUG
import Foundation
import GamesLibraryCore

/// Deterministic outbound stub for UI tests. Activated via `-UITesting` launch argument.
///
/// Configure at the composition root (e.g. empty `games` for the no-results scenario).
/// Mutable so individual UI tests can swap stub data without ViewModel hacks.
final class StubGamesRepository: GamesRepositoryPort, @unchecked Sendable {
	var games: [GameSummary]
	var detailsDescription: String
	var detailsWebsite: String?
	var detailsPlaytime: Int?
	/// How many upcoming `gameDetails` calls should throw before succeeding.
	var detailsFailuresRemaining: Int

	init(
		games: [GameSummary] = StubGamesRepository.defaultGames,
		detailsDescription: String = "Stub description for UI testing.",
		detailsWebsite: String? = "https://example.com/stub-game",
		detailsPlaytime: Int? = 12,
		detailsFailuresRemaining: Int = 0
	) {
		self.games = games
		self.detailsDescription = detailsDescription
		self.detailsWebsite = detailsWebsite
		self.detailsPlaytime = detailsPlaytime
		self.detailsFailuresRemaining = detailsFailuresRemaining
	}

	static let defaultGames: [GameSummary] = [
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

	func searchGames(query: String, page: Int, pageSize: Int, ordering: String?) async throws -> [GameSummary] {
		if page > 1 {
			return []
		}
		let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else {
			return games
		}
		return games.filter { ($0.name ?? "").localizedCaseInsensitiveContains(trimmed) }
	}

	func gameDetails(id: GameID) async throws -> GameDetails {
		if detailsFailuresRemaining > 0 {
			detailsFailuresRemaining -= 1
			throw StubGamesRepositoryError.forcedFailure
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
			descriptionRaw: detailsDescription,
			website: detailsWebsite,
			playtime: detailsPlaytime
		)
	}
}

enum StubGamesRepositoryError: Error {
	case forcedFailure
}
#endif
