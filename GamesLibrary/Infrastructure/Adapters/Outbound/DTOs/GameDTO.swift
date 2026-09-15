import Foundation

struct GameDTO: nonisolated Decodable, Sendable {
    let id: Int?
    let slug: String?
    let name: String?
    let nameOriginal: String?
    let description: String?
    let rawDescription: String?
    let metacritic: Int?
    let released: String?
    let tba: Bool?
    let updated: String?
    let backgroundImage: String?
    let website: String?
    let ratingTop: Int?
    let rating: Double?
    let playtime: Int?
    let esrbRating: ESRBRatingDTO?
    let platforms: [PlatformEntryDTO]?

    enum CodingKeys: String, CodingKey {
        case id, slug, name, rating, description, metacritic, released, tba, updated, website, playtime, platforms
        case rawDescription = "description_raw"
        case nameOriginal = "name_original"
        case backgroundImage = "background_image"
        case ratingTop = "rating_top"
        case esrbRating = "esrb_rating"
    }
}
