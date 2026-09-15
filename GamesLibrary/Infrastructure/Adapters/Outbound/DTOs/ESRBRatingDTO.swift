import Foundation

struct ESRBRatingDTO: Equatable, nonisolated Decodable, Sendable {
    let id: Int?
    let slug: String?
    let name: String?
}
