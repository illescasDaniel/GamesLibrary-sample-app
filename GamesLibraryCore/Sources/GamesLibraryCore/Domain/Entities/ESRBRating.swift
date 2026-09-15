public struct ESRBRating: Equatable, Sendable, Hashable {
    public let id: Int?
    public let slug: String?
    public let name: String?

    public init(id: Int? = nil, slug: String? = nil, name: String? = nil) {
        self.id = id
        self.slug = slug
        self.name = name
    }
}
