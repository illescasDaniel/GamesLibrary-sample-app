import Foundation
@testable import GamesLibrary

extension GameSearchItemDTO {
	@MainActor
	static func dummy(id: Int = 1, name: String = "Test Game") -> GameSearchItemDTO {
		let data = Data(#"{ "id": \#(id), "name": "\#(name)", "rating": 4.5 }"#.utf8)
		return try! JSONDecoder().decode(GameSearchItemDTO.self, from: data)
	}
}

extension GameDTO {
	@MainActor
	static func dummy(id: Int = 1) -> GameDTO {
		let data = Data(#"{ "id": \#(id), "name": "Test Game", "rating": 4.5 }"#.utf8)
		return try! JSONDecoder().decode(GameDTO.self, from: data)
	}
}

extension GamesOutputDTO {
	static func dummy(results: [GameSearchItemDTO]) -> GamesOutputDTO {
		GamesOutputDTO(count: results.count, next: nil, previous: nil, results: results)
	}
}
