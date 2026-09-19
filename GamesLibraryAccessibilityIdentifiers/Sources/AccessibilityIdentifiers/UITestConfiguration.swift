import Foundation

/// Scenario payload passed via `UITEST_CONFIG`. Add per-screen nested configs instead of new env keys.
public struct UITestConfiguration: Codable, Equatable, Sendable {
	public var gamesList: GamesList
	public var gameDetails: GameDetails

	public init(
		gamesList: GamesList = .init(),
		gameDetails: GameDetails = .init()
	) {
		self.gamesList = gamesList
		self.gameDetails = gameDetails
	}

	public static let `default` = UITestConfiguration()

	/// Games list screen stub knobs.
	///
	/// `responses == nil` → DEBUG `UITestSupport` uses built-in `(1, "")` fixtures.
	/// Pass an explicit `responses` table for empty results, custom rows, search, or pagination.
	/// Keys are `"page|searchText"` (see `searchKey(page:searchText:)`); `searchText` must not contain `|`.
	public struct GamesList: Codable, Equatable, Sendable {
		public var responses: [String: [GameSummaryFixture]]?

		public init(responses: [String: [GameSummaryFixture]]? = nil) {
			self.responses = responses
		}

		/// Encoded lookup key for `(page, searchText)` — e.g. `"1|"`, `"1|zelda"`.
		public static func searchKey(page: Int, searchText: String) -> String {
			"\(page)|\(searchText)"
		}

		/// Initial load returns no rows (`(1, "")` → `[]`).
		public static let empty = GamesList(
			responses: [searchKey(page: 1, searchText: ""): []]
		)
	}

	/// Codable stand-in for list/details stub rows (keep Core `GameSummary` out of this package).
	public struct GameSummaryFixture: Codable, Equatable, Sendable {
		public var id: Int
		public var name: String?
		public var rating: Double?
		public var released: String?
		public var backgroundImageURL: String?
		public var esrbRating: ESRBRatingFixture?
		public var platforms: [PlatformInfoFixture]?

		public init(
			id: Int,
			name: String? = nil,
			rating: Double? = nil,
			released: String? = nil,
			backgroundImageURL: String? = nil,
			esrbRating: ESRBRatingFixture? = nil,
			platforms: [PlatformInfoFixture]? = nil
		) {
			self.id = id
			self.name = name
			self.rating = rating
			self.released = released
			self.backgroundImageURL = backgroundImageURL
			self.esrbRating = esrbRating
			self.platforms = platforms
		}

		public static let stubGameOne = GameSummaryFixture(
			id: 1,
			name: "Stub Game One",
			rating: 4.5,
			released: "2024-01-01",
			esrbRating: ESRBRatingFixture(id: 1, slug: "teen", name: "Teen"),
			platforms: [
				PlatformInfoFixture(id: 1, name: "PC"),
				PlatformInfoFixture(id: 2, name: "macOS"),
			]
		)

		public static let stubGameTwo = GameSummaryFixture(
			id: 2,
			name: "Stub Game Two",
			rating: 4.0,
			released: "2023-06-15",
			esrbRating: ESRBRatingFixture(id: 2, slug: "mature", name: "Mature"),
			platforms: [
				PlatformInfoFixture(id: 3, name: "PlayStation 5"),
			]
		)
	}

	public struct ESRBRatingFixture: Codable, Equatable, Sendable {
		public var id: Int?
		public var slug: String?
		public var name: String?

		public init(id: Int? = nil, slug: String? = nil, name: String? = nil) {
			self.id = id
			self.slug = slug
			self.name = name
		}
	}

	public struct PlatformInfoFixture: Codable, Equatable, Sendable {
		public var id: Int?
		public var name: String?

		public init(id: Int? = nil, name: String? = nil) {
			self.id = id
			self.name = name
		}
	}

	/// Game details screen stub knobs.
	///
	/// `responses == nil` → DEBUG `UITestSupport` builds one success outcome per game from the list stub.
	/// Keys are game ids; each value is an ordered outcome queue consumed per `getGameDetails` call.
	public struct GameDetails: Codable, Equatable, Sendable {
		public var responses: [Int: [DetailsOutcome]]?

		public init(responses: [Int: [DetailsOutcome]]? = nil) {
			self.responses = responses
		}

		/// First call for `id` throws; second returns `details` (Retry UI tests).
		public static func failingThenSucceeding(
			id: Int = GameSummaryFixture.stubGameOne.id,
			details: GameDetailsFixture = .stubGameOne
		) -> GameDetails {
			GameDetails(
				responses: [id: [.failure, .success(details)]]
			)
		}
	}

	public enum DetailsOutcome: Codable, Equatable, Sendable {
		case success(GameDetailsFixture)
		case failure
	}

	/// Codable stand-in for details stub payloads (keep Core `GameDetails` out of this package).
	public struct GameDetailsFixture: Codable, Equatable, Sendable {
		public var summary: GameSummaryFixture
		public var descriptionRaw: String?
		public var website: String?
		public var playtime: Int?

		public init(
			summary: GameSummaryFixture,
			descriptionRaw: String? = nil,
			website: String? = nil,
			playtime: Int? = nil
		) {
			self.summary = summary
			self.descriptionRaw = descriptionRaw
			self.website = website
			self.playtime = playtime
		}

		public static let stubGameOne = GameDetailsFixture(
			summary: .stubGameOne,
			descriptionRaw: "Stub description for UI testing.",
			website: "https://example.com/stub-game",
			playtime: 12
		)
	}
}
