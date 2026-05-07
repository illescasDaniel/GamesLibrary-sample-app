//
//  Game.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Foundation

struct GameSearchItem: Identifiable, Decodable {
	let id: Int?
	let slug: String?
	let name: String?
	let released: String?
	let tba: Bool?
	let backgroundImage: String?
	let rating: Double?
	let ratingTop: Int?
	let ratings: Ratings?
	let ratingsCount: Int?
	let reviewsTextCount: Int?
	let added: Int?
	let addedByStatus: AddedByStatus?
	let metacritic: Int?
	let playtime: Int?
	let suggestionsCount: Int?
	let updated: String?
	let esrbRating: ESRBRating?
	let platforms: [PlatformEntry]?

	enum CodingKeys: String, CodingKey {
		case id, slug, name, released, tba, rating, ratings, added, metacritic, playtime, updated, platforms
		case backgroundImage = "background_image"
		case ratingTop = "rating_top"
		case ratingsCount = "ratings_count"
		case reviewsTextCount = "reviews_text_count"
		case addedByStatus = "added_by_status"
		case suggestionsCount = "suggestions_count"
		case esrbRating = "esrb_rating"
	}
}

// Nested Models
extension GameSearchItem {
	/// Placeholder for the empty `{}` ratings object in the JSON
	struct Ratings: Decodable {
		// Add properties here if the API populates this later
	}

	/// Placeholder for the empty `{}` added_by_status object in the JSON
	struct AddedByStatus: Decodable {
		// Add properties here if the API populates this later
	}

	struct ESRBRating: Decodable {
		let id: Int?
		let slug: String?
		let name: String?
	}

	struct PlatformEntry: Decodable {
		let platform: PlatformDetail?
		let releasedAt: String?
		let requirements: Requirements?

		enum CodingKeys: String, CodingKey {
			case platform, requirements
			case releasedAt = "released_at"
		}
	}

	struct PlatformDetail: Decodable {
		let id: Int?
		let slug: String?
		let name: String?
	}

	struct Requirements: Decodable {
		let minimum: String?
		let recommended: String?
	}
}
