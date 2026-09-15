import Foundation

struct GamesOutputDTO: nonisolated Decodable, Sendable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [GameSearchItemDTO]
}
