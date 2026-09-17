import Foundation

struct PlatformEntryDTO: Equatable, nonisolated Decodable, Sendable {
	let platform: PlatformInfoDTO?
	let releasedAt: String?
	let requirements: Requirements?

	enum CodingKeys: String, CodingKey {
		case platform
		case releasedAt = "released_at"
		case requirements
	}

	struct PlatformInfoDTO: Equatable, nonisolated Decodable, Sendable {
		let id: Int?
		let slug: String?
		let name: String?
	}

	struct Requirements: Equatable, nonisolated Decodable, Sendable {
		let minimum: String?
		let recommended: String?
	}
}
