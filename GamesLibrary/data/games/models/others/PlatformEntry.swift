//
//  PlatformEntry.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 8/5/26.
//

import Foundation

struct PlatformEntry: Equatable, Decodable {
	let platform: PlatformInfo?
	let releasedAt: String?
	let requirements: Requirements?

	enum CodingKeys: String, CodingKey {
		case platform
		case releasedAt = "released_at"
		case requirements
	}

	struct PlatformInfo: Equatable, Decodable {
		let id: Int?
		let slug: String?
		let name: String?
	}

	struct Requirements: Equatable, Decodable {
		let minimum: String?
		let recommended: String?
	}

}
