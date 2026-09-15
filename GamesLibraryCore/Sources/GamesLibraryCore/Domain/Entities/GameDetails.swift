public struct GameDetails: Equatable, Sendable {
	public let summary: GameSummary
	public let descriptionHTML: String?
	public let descriptionRaw: String?
	public let website: String?
	public let playtime: Int?

	public init(
		summary: GameSummary,
		descriptionHTML: String? = nil,
		descriptionRaw: String? = nil,
		website: String? = nil,
		playtime: Int? = nil
	) {
		self.summary = summary
		self.descriptionHTML = descriptionHTML
		self.descriptionRaw = descriptionRaw
		self.website = website
		self.playtime = playtime
	}

	public var id: GameID { summary.id }
	public var name: String? { summary.name }
	public var rating: Double? { summary.rating }
	public var released: String? { summary.released }
	public var backgroundImageURL: String? { summary.backgroundImageURL }
	public var esrbRating: ESRBRating? { summary.esrbRating }
	public var platforms: [PlatformInfo]? { summary.platforms }
}
