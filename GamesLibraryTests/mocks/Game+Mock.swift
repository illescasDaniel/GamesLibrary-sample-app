import Foundation
@testable import GamesLibrary

extension Game {
	@MainActor
	static func dummy(id: Int = 1) -> Game {
		let data = Data(#"{ "id": \#(id), "name": "Test Game", "rating": 4.5 }"#.utf8)
		return try! JSONDecoder().decode(Game.self, from: data)
	}
}
