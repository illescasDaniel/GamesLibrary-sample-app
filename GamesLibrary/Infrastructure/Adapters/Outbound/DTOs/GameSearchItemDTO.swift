import Foundation

struct GameSearchItemDTO: Identifiable, Equatable, nonisolated Decodable, Sendable {
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
	let esrbRating: ESRBRatingDTO?
	let platforms: [PlatformEntryDTO]?

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

extension GameSearchItemDTO {
	struct Ratings: Equatable, nonisolated Decodable, Sendable {}

	struct AddedByStatus: Equatable, nonisolated Decodable, Sendable {}
}
