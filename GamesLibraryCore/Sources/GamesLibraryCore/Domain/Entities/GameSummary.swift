public struct GameSummary: Identifiable, Equatable, Sendable, Hashable {
    public let id: GameID
    public let name: String?
    public let rating: Double?
    public let released: String?
    public let backgroundImageURL: String?
    public let esrbRating: ESRBRating?
    public let platforms: [PlatformInfo]?

    public init(
        id: GameID,
        name: String? = nil,
        rating: Double? = nil,
        released: String? = nil,
        backgroundImageURL: String? = nil,
        esrbRating: ESRBRating? = nil,
        platforms: [PlatformInfo]? = nil
    ) {
        self.id = id
        self.name = name
        self.rating = rating
        self.released = released
        self.backgroundImageURL = backgroundImageURL
        self.esrbRating = esrbRating
        self.platforms = platforms
    }
}
