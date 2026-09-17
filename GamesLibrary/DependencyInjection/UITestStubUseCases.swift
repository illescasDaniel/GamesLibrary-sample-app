#if DEBUG
import Foundation
import Synchronization
import AccessibilityIdentifiers
import GamesLibraryCore

/// Deterministic inbound stubs for UI tests and SwiftUI previews.
/// Wired via `UITestSupport.makeOverrides()` or `DebugAppContainer.Overrides`.
/// `nonisolated` so values can seed default parameters on Sendable stub inits
/// (module uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`).
enum UITestFixtures {
	nonisolated static let defaultGames: [GameSummary] = [
		UITestConfiguration.GameSummaryFixture.stubGameOne.toDomain(),
		UITestConfiguration.GameSummaryFixture.stubGameTwo.toDomain(),
	]

	nonisolated static let defaultDetailsByID: [GameID: GameDetails] = [
		GameID(UITestConfiguration.GameSummaryFixture.stubGameOne.id):
			UITestConfiguration.GameDetailsFixture.stubGameOne.toDomain(),
	]
}

/// Dictionary key for canned search replies (`(page, searchText)` as a Hashable struct).
/// `nonisolated` so dictionary lookup works under `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.
nonisolated struct SearchStubKey: Hashable, Sendable {
	var page: Int
	var searchText: String
}

/// Canned `(page, searchText)` → games lookup. Missing keys return `[]`.
///
/// Port methods are `nonisolated` so `Sendable` use-case calls from a MainActor ViewModel
/// do not deadlock on a MainActor-isolated stub (default actor isolation).
final class StubSearchGamesUseCase: SearchGamesUseCasePort, @unchecked Sendable {
	private let responses: [SearchStubKey: [GameSummary]]

	init(responses: [SearchStubKey: [GameSummary]]) {
		self.responses = responses
	}

	/// Registers a single `(1, "")` reply (typical list preview / happy-path load).
	static func constant(_ games: [GameSummary]) -> StubSearchGamesUseCase {
		StubSearchGamesUseCase(responses: [SearchStubKey(page: 1, searchText: ""): games])
	}

	nonisolated func callAsFunction(page: Int, searchText: String) async throws -> [GameSummary] {
		responses[SearchStubKey(page: page, searchText: searchText)] ?? []
	}
}

/// One canned details reply (success payload or failure).
enum DetailsStubOutcome: Sendable {
	case success(GameDetails)
	case failure(any Error)
}

/// Canned `GameID` → outcome queue. Each call consumes the next outcome for that id.
/// `repeating` entries always succeed (previews / `.constant`) without consuming.
final class StubGetGameDetailsUseCase: GetGameDetailsUseCasePort, @unchecked Sendable {
	private let repeating: [GameID: GameDetails]
	private let queues: Mutex<[GameID: [DetailsStubOutcome]]>

	init(
		responses: [GameID: [DetailsStubOutcome]] = [:],
		repeating: [GameID: GameDetails] = [:]
	) {
		self.repeating = repeating
		self.queues = Mutex(responses)
	}

	/// Always returns `details` for `details.id` (typical details preview).
	static func constant(_ details: GameDetails) -> StubGetGameDetailsUseCase {
		StubGetGameDetailsUseCase(repeating: [details.id: details])
	}

	nonisolated func callAsFunction(id: GameID) async throws -> GameDetails {
		if let details = repeating[id] {
			return details
		}
		return try queues.withLock { responses in
			guard var queue = responses[id], !queue.isEmpty else {
				throw StubGetGameDetailsUseCaseError.noResponse(for: id)
			}
			let outcome = queue.removeFirst()
			responses[id] = queue
			switch outcome {
			case .success(let details):
				return details
			case .failure(let error):
				throw error
			}
		}
	}
}

enum StubGetGameDetailsUseCaseError: Error {
	case noResponse(for: GameID)
	case forcedFailure
}

extension UITestConfiguration.GameSummaryFixture {
	nonisolated func toDomain() -> GameSummary {
		GameSummary(
			id: GameID(id),
			name: name,
			rating: rating,
			released: released,
			backgroundImageURL: backgroundImageURL,
			esrbRating: esrbRating.map {
				ESRBRating(id: $0.id, slug: $0.slug, name: $0.name)
			},
			platforms: platforms?.map {
				PlatformInfo(id: $0.id, name: $0.name)
			}
		)
	}
}

extension UITestConfiguration.GameDetailsFixture {
	nonisolated func toDomain() -> GameDetails {
		GameDetails(
			summary: summary.toDomain(),
			descriptionRaw: descriptionRaw,
			website: website,
			playtime: playtime
		)
	}
}

extension UITestConfiguration.DetailsOutcome {
	nonisolated func toDomain() -> DetailsStubOutcome {
		switch self {
		case .success(let fixture):
			.success(fixture.toDomain())
		case .failure:
			.failure(StubGetGameDetailsUseCaseError.forcedFailure)
		}
	}
}
#endif
