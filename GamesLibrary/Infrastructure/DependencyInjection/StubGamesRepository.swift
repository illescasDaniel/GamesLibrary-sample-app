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

	init(
		games: [GameSummary] = StubGamesRepository.defaultGames,
		detailsDescription: String = "Stub description for UI testing."
	) {
		self.games = games
		self.detailsDescription = detailsDescription
	}

	static let defaultGames: [GameSummary] = [
		GameSummary(id: GameID(1), name: "Stub Game One", rating: 4.5, released: "2024-01-01"),
		GameSummary(id: GameID(2), name: "Stub Game Two", rating: 4.0, released: "2023-06-15"),
	]

	/// Builds a stub from UI-test launch environment (`UITestSupport`).
	static func forUITests() -> StubGamesRepository {
		if UITestSupport.shouldForceEmptyResults {
			StubGamesRepository(games: [])
		} else {
			StubGamesRepository()
		}
	}

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
		let summary = games.first { $0.id == id }
			?? GameSummary(
				id: id,
				name: "Stub Game \(id.rawValue)",
				rating: 4.5,
				released: "2024-01-01"
			)
		return GameDetails(
			summary: summary,
			descriptionRaw: detailsDescription
		)
	}
}
#endif
