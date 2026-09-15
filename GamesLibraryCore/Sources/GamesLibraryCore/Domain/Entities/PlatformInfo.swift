public struct PlatformInfo: Equatable, Sendable, Hashable {
	public let id: Int?
	public let name: String?

	public init(id: Int? = nil, name: String? = nil) {
		self.id = id
		self.name = name
	}
}
