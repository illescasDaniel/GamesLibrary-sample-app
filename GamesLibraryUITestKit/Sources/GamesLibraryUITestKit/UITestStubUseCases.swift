import Foundation
import AccessibilityIdentifiers
import GamesLibraryCore

/// Deterministic inbound stubs for UI tests and SwiftUI previews.
public enum UITestFixtures {
	public static let defaultGames: [GameSummary] = [
		UITestConfiguration.GameSummaryFixture.stubGameOne.toDomain(),
		UITestConfiguration.GameSummaryFixture.stubGameTwo.toDomain(),
	]

	public static let defaultDetailsByID: [GameID: GameDetails] = [
		GameID(UITestConfiguration.GameSummaryFixture.stubGameOne.id):
			UITestConfiguration.GameDetailsFixture.stubGameOne.toDomain(),
	]
}

/// Dictionary key for canned search replies (`page` + `searchText`).
public struct SearchStubKey: Hashable, Sendable {
	public var page: Int
	public var searchText: String

	public init(page: Int, searchText: String) {
		self.page = page
		self.searchText = searchText
	}
}

/// Canned `(page, searchText)` → games lookup. Missing keys return `[]`.
@MainActor
public final class StubSearchGamesUseCase: SearchGamesUseCasePort {
	private var responses: [SearchStubKey: [GameSummary]]

	public init(responses: [SearchStubKey: [GameSummary]] = [:]) {
		self.responses = responses
	}

	/// Registers a single `(1, "")` reply (typical list preview / happy-path load).
	public static func constant(_ games: [GameSummary]) -> StubSearchGamesUseCase {
		StubSearchGamesUseCase(responses: [SearchStubKey(page: 1, searchText: ""): games])
	}

	public func apply(responses: [SearchStubKey: [GameSummary]]) {
		self.responses = responses
	}

	public func callAsFunction(page: Int, searchText: String) async throws -> [GameSummary] {
		responses[SearchStubKey(page: page, searchText: searchText)] ?? []
	}
}

/// One canned details reply (success payload or failure).
public enum DetailsStubOutcome: Sendable {
	case success(GameDetails)
	case failure(any Error)
}

/// Canned `GameID` → outcome queue. Each call consumes the next outcome for that id.
/// `repeating` entries always succeed (previews / `.constant`) without consuming.
@MainActor
public final class StubGetGameDetailsUseCase: GetGameDetailsUseCasePort {
	private var repeating: [GameID: GameDetails]
	private var responses: [GameID: [DetailsStubOutcome]]

	public init(
		responses: [GameID: [DetailsStubOutcome]] = [:],
		repeating: [GameID: GameDetails] = [:]
	) {
		self.responses = responses
		self.repeating = repeating
	}

	/// Always returns `details` for `details.id` (typical details preview).
	public static func constant(_ details: GameDetails) -> StubGetGameDetailsUseCase {
		StubGetGameDetailsUseCase(repeating: [details.id: details])
	}

	public func apply(
		responses: [GameID: [DetailsStubOutcome]],
		repeating: [GameID: GameDetails] = [:]
	) {
		self.responses = responses
		self.repeating = repeating
	}

	public func callAsFunction(id: GameID) async throws -> GameDetails {
		if let details = repeating[id] {
			return details
		}
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

public enum StubGetGameDetailsUseCaseError: Error {
	case noResponse(for: GameID)
	case forcedFailure
}

extension UITestConfiguration.GameSummaryFixture {
	public func toDomain() -> GameSummary {
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
	public func toDomain() -> GameDetails {
		GameDetails(
			summary: summary.toDomain(),
			descriptionRaw: descriptionRaw,
			website: website,
			playtime: playtime
		)
	}
}

extension UITestConfiguration.DetailsOutcome {
	public func toDomain() -> DetailsStubOutcome {
		switch self {
		case .success(let fixture):
			.success(fixture.toDomain())
		case .failure:
			.failure(StubGetGameDetailsUseCaseError.forcedFailure)
		}
	}
}
