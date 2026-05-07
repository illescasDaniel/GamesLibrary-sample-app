//
//  Game.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 7/5/26.
//

import Foundation

struct Game: Decodable {

	let rating: Double

	let id: Int?
	let slug: String?
	let name: String?
	let nameOriginal: String?
	let description: String?
	let metacritic: Int?
	let metacriticPlatforms: [GamePlatformMetacritic]?
	let released: String?
	let tba: Bool?
	let updated: String?
	let backgroundImage: String?
	let backgroundImageAdditional: String?
	let website: String?
	let ratingTop: Int?

//	let ratings: [Int]? // sometimes an [Int], sometimes a dictionary...
	let reactions: [String: Int]?
	let added: Int?
	let addedByStatus: [String: Int]?

	let playtime: Int?
	let screenshotsCount: Int?
	let moviesCount: Int?
	let creatorsCount: Int?
	let achievementsCount: Int?
	let parentAchievementsCount: Int?
	let redditUrl: String?
	let redditName: String?
	let redditDescription: String?
	let redditLogo: String?
	let redditCount: Int?
	let twitchCount: Int?
	let youtubeCount: Int?
	let reviewsTextCount: Int?
	let ratingsCount: Int?
	let suggestionsCount: Int?
	let alternativeNames: [String]?
	let metacriticUrl: String?
	let parentsCount: Int?
	let additionsCount: Int?
	let gameSeriesCount: Int?

	let esrbRating: ESRBRating?
	let platforms: [PlatformElement]?

	enum CodingKeys: String, CodingKey {
		case id, slug, name, rating, description, metacritic, released, tba, updated, website, /*ratings,*/ reactions, added, playtime, platforms
		case nameOriginal = "name_original"
		case metacriticPlatforms = "metacritic_platforms"
		case backgroundImage = "background_image"
		case backgroundImageAdditional = "background_image_additional"
		case ratingTop = "rating_top"
		case addedByStatus = "added_by_status"
		case screenshotsCount = "screenshots_count"
		case moviesCount = "movies_count"
		case creatorsCount = "creators_count"
		case achievementsCount = "achievements_count"
		case parentAchievementsCount = "parent_achievements_count"
		case redditUrl = "reddit_url"
		case redditName = "reddit_name"
		case redditDescription = "reddit_description"
		case redditLogo = "reddit_logo"
		case redditCount = "reddit_count"
		case twitchCount = "twitch_count"
		case youtubeCount = "youtube_count"
		case reviewsTextCount = "reviews_text_count"
		case ratingsCount = "ratings_count"
		case suggestionsCount = "suggestions_count"
		case alternativeNames = "alternative_names"
		case metacriticUrl = "metacritic_url"
		case parentsCount = "parents_count"
		case additionsCount = "additions_count"
		case gameSeriesCount = "game_series_count"
		case esrbRating = "esrb_rating"
	}
}

extension Game {
	struct GamePlatformMetacritic: Codable {
		let metascore: Int?
		let url: String?
	}

	struct ESRBRating: Codable {
		let id: Int?
		let slug: String?
		let name: String?
	}

	struct PlatformElement: Codable {
		let platform: PlatformInfo?
		let releasedAt: String?
		let requirements: Requirements?

		enum CodingKeys: String, CodingKey {
			case platform
			case releasedAt = "released_at"
			case requirements
		}
	}

	struct PlatformInfo: Codable {
		let id: Int?
		let slug: String?
		let name: String?
	}

	struct Requirements: Codable {
		let minimum: String?
		let recommended: String?
	}
}
